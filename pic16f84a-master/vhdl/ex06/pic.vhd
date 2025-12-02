
library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.operation_package.all;

entity pic is
    generic        (N           : positive := 2 ** 7);
    port           (op_code     : in std_logic_vector(13 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    result      : out std_logic_vector (7 downto 0));
end entity pic;

architecture rtl of pic is    
    component alu_easier is
        port       (A, B        : in std_logic_vector (7 downto 0);
                    operation   : in op_type;
                    bit_select  : in std_logic_vector (2 downto 0);
                    status_in   : in std_logic_vector (2 downto 0);
                    result      : out std_logic_vector (7 downto 0);
                    status      : out std_logic_vector (2 downto 0));
    end component;

    signal A_alu                : std_logic_vector (7 downto 0);
    signal B_alu                : std_logic_vector (7 downto 0);
    signal alu_result           : std_logic_vector (7 downto 0);
    signal alu_op               : op_type;
    signal status_alu_to_mem    : std_logic_vector (2 downto 0);
    signal status_mem_to_alu    : std_logic_vector (2 downto 0);
    
    component decoder is 
    port(op_code        : in std_logic_vector(13 downto 0);
         operation      : out op_type;
         address        : out std_logic_vector(10 downto 0);
         K              : out std_logic_vector(7 downto 0);
         mem_address    : out std_logic_vector(6 downto 0);
         bit_select     : out std_logic_vector(2 downto 0);
         we             : out std_logic;
         re             : out std_logic);
    end component decoder;
    
    signal to_decoder   : std_logic_vector(13 downto 0) := "00000000000000";
    signal operation    : op_type;
    signal address      : std_logic_vector(10 downto 0);
    signal K            : std_logic_vector(7 downto 0);
    signal mem_address  : std_logic_vector(6 downto 0);
    signal bit_select   : std_logic_vector(2 downto 0);
    signal we_mem       : std_logic;
    signal re           : std_logic; 

    component W_register is
        port       (data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    data_out    : out std_logic_vector(7 downto 0));
    end component;
    signal we_wreg : std_logic;
    signal W_out   : std_logic_vector (7 downto 0);

    component data_memory is
        generic    (N           : positive);
        port       (address     : in std_logic_vector(6 downto 0);
                    data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    status_in   : in std_logic_vector(2 downto 0);
                    status_out  : out std_logic_vector(2 downto 0);
                    data_out    : out std_logic_vector(7 downto 0));
    end component;
    signal mem_out : std_logic_vector (7 downto 0);

    signal state : possible_states := iFetch;
    signal program_counter : integer := 0;
    --Since this version is being fed instructions from the testbench, the program counter does nothing.
begin

    running : process (clk) is
    begin
        if rising_edge(clk) then
            we_wreg <= '0';
            if reset then 
                state <= iFetch;
                program_counter <= 0;
            else
                case state is
                    when iFetch =>
                        to_decoder <= op_code;
                        state <= Mread;
                    when Mread =>
                        if re then
                            A_alu <= mem_out;
                        else
                            A_alu <= K;
                        end if;
                        B_alu <= W_out;
                        state <= Execute;   
                    when Execute =>
                        alu_op <= operation;
                        state <= Mwrite;
                        if we_mem = '0' then
                            we_wreg <= '1';
                        end if;
                    when Mwrite =>
                        state <= iFetch;
                        program_counter <= program_counter + 1;
                    when others =>
                        state <= iFetch;
                end case;
            end if;
        end if;
    end process;
    
    result <= B_alu;

    alu : alu_easier
        port map   (A => A_alu,
                    B => B_alu,
                    operation => alu_op,
                    bit_select => bit_select,
                    status_in => status_mem_to_alu,
                    result => alu_result,
                    status => status_alu_to_mem);

    w_reg : W_register
        port map   (data_in => alu_result,
                    clk => clk,
                    reset => reset,
                    we => we_wreg,
                    data_out => W_out);

    mem : data_memory
        generic map (N => N)
        port map   (address => mem_address,
                    data_in => alu_result,
                    clk => clk,
                    reset => reset,
                    we => we_mem,
                    status_in => status_alu_to_mem,
                    status_out => status_mem_to_alu,
                    data_out => mem_out);
                    
    dec : decoder 
        port map   (op_code => to_decoder,
                    operation => operation,
                    address => address,
                    K => K,
                    mem_address => mem_address,
                    bit_select => bit_select,
                    we => we_mem,
                    re => re);
end architecture;