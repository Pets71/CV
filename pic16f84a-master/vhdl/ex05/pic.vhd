
library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.operation_package.all;

entity pic is
    generic        (N           : positive := 2 ** 7);
    port           (A, B        : in std_logic_vector (7 downto 0);
                    operation   : in op_type;
                    bit_select  : in std_logic_vector (2 downto 0);
                    address     : in std_logic_vector(6 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we_mem      : in std_logic;
                    re_mem      : in std_logic;
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

    signal A_alu : std_logic_vector (7 downto 0);
    signal alu_result : std_logic_vector (7 downto 0);
    signal status_alu_to_mem : std_logic_vector (2 downto 0);
    signal status_mem_to_alu : std_logic_vector (2 downto 0);
    
-- I implemented W_register before realizing that it was not needed, please ignore :D
    component W_register is
        port       (data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    data_out    : out std_logic_vector(7 downto 0));
    end component;
    signal we_wreg : std_logic;

    component memory_block is
        generic    (N           : positive);
        port       (address     : in std_logic_vector(6 downto 0);
                    data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    re          : in std_logic;
                    status_in   : in std_logic_vector(2 downto 0);
                    status_out  : out std_logic_vector(2 downto 0);
                    data_out    : out std_logic_vector(7 downto 0));
    end component;
    signal mem_out : std_logic_vector (7 downto 0);
begin    
    running : process (clk) is
    begin
        if rising_edge(clk) then
            we_wreg <= '0';
            if reset then 
                null;
            else
                if re_mem then
                    A_alu <= mem_out;
                else
                    A_alu <= A;
                end if;
                if (we_mem = '0') then
                    we_wreg <= '1';
                end if;
            end if;
        end if;
    end process;

    alu : alu_easier
        port map   (A => A_alu,
                    B => B,
                    operation => operation,
                    bit_select => bit_select,
                    status_in => status_mem_to_alu,
                    result => alu_result,
                    status => status_alu_to_mem);

    w_reg : W_register
        port map   (data_in => alu_result,
                    clk => clk,
                    reset => reset,
                    we => we_wreg,
                    data_out => result);

    mem : memory_block
        generic map (N => N)
        port map   (address => address,
                    data_in => alu_result,
                    clk => clk,
                    reset => reset,
                    we => we_mem,
                    re => re_mem,
                    status_in => status_alu_to_mem,
                    status_out => status_mem_to_alu,
                    data_out => mem_out);                   

end architecture;