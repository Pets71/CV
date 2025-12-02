----------------------------------
--PIC microcontroller main entity
----------------------------------
--N                 : Length of the data memory, defaults to 2^7, which is correct for PIC16F84A.
--op_code           : Given opcode, which is transformed in the decoder, 14 bits.
--clk               : Clock signal, 1 bit.
--reset             : Reset signal, 1 bit.
--result            : Result of the latest ALU operation, mainly exists as a testing output, 8 bits.
--pc                : Current value of the program counter, handled by the program counter, 13 bits.
--PORTA and PORTB   : Outputs from predefined register locations, which act as "ports", 5 and 8 bits respectively.



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.operation_package.all;

entity pic_cl is
    generic        (N           : positive := 2 ** 7);
    port           (op_code     : in std_logic_vector(13 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    result      : out std_logic_vector(7 downto 0);
                    pc          : out std_logic_vector(12 downto 0);
                    PORTA       : out std_logic_vector(4 downto 0);
                    PORTB       : out std_logic_vector(7 downto 0));
end entity pic_cl;

architecture rtl of pic_cl is   

    component program_counter is
        port   (goto_addr       : in std_logic_vector(12 downto 0);
                clk             : in std_logic;
                reset           : in std_logic;
                push            : in std_logic;
                pop             : in std_logic;
                goto_bool       : in std_logic;
                fetch           : in std_logic;
                pc_in           : in std_logic_vector(12 downto 0);
                pc_out          : out std_logic_vector(12 downto 0);
                can_exec        : out std_logic);
    end component program_counter;

    --Internal connections from/to the PC

    signal goto_addr                                : std_logic_vector (12 downto 0);
    signal addr_top_bits                            : std_logic_vector (1 downto 0);
    signal push, pop, goto_bool, fetch, can_exec_pc : std_logic; 

    component alu_easier is
        port       (A, B        : in std_logic_vector (7 downto 0);
                    operation   : in op_type;
                    bit_select  : in std_logic_vector (2 downto 0);
                    status_in   : in std_logic_vector (2 downto 0);
                    can_exec    : out std_logic;
                    result      : out std_logic_vector (7 downto 0);
                    status      : out std_logic_vector (2 downto 0));
    end component;

    --Internal connections from/to the ALU

    signal A_alu                : std_logic_vector (7 downto 0);
    signal B_alu                : std_logic_vector (7 downto 0);
    signal alu_result           : std_logic_vector (7 downto 0);
    signal alu_op               : op_type;
    signal status_alu_to_mem    : std_logic_vector (2 downto 0);
    signal status_mem_to_alu    : std_logic_vector (2 downto 0);
    signal can_exec_alu         : std_logic;
    
    component decoder is 
        port   (op_code        : in std_logic_vector(13 downto 0);
                operation      : out op_type;
                address        : out std_logic_vector(10 downto 0);
                K              : out std_logic_vector(7 downto 0);
                mem_address    : out std_logic_vector(6 downto 0);
                bit_select     : out std_logic_vector(2 downto 0);
                no_write       : out std_logic;
                we             : out std_logic;
                re             : out std_logic);
    end component decoder;
    
    --Internal connections from/to the decoder

    signal to_decoder   : std_logic_vector(13 downto 0) := "00000000000000";
    signal operation    : op_type;
    signal address      : std_logic_vector(10 downto 0);
    signal K            : std_logic_vector(7 downto 0);
    signal mem_address  : std_logic_vector(6 downto 0);
    signal bit_select   : std_logic_vector(2 downto 0);
    signal we_mem_dec   : std_logic;
    signal no_write     : std_logic;
    signal re           : std_logic; 

    component W_register is
        port       (data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    data_out    : out std_logic_vector(7 downto 0));
    end component;

    --Internal connections from/to the W-register

    signal we_wreg : std_logic;
    signal W_out   : std_logic_vector (7 downto 0);

    component data_memory is
        generic    (N           : positive);
        port       (address     : in std_logic_vector(6 downto 0);
                    data_in     : in std_logic_vector(7 downto 0);
                    clk         : in std_logic;
                    reset       : in std_logic;
                    we          : in std_logic;
                    pc_in       : in std_logic_vector(12 downto 0);
                    pc_out      : out std_logic_vector(12 downto 0);
                    status_in   : in std_logic_vector(2 downto 0);
                    status_out  : out std_logic_vector(2 downto 0);
                    data_out    : out std_logic_vector(7 downto 0);
                    PORTA       : out std_logic_vector(4 downto 0);
                    PORTB       : out std_logic_vector(7 downto 0));
    end component;

    --Internal connections from/to the data memory

    signal mem_out      : std_logic_vector (7 downto 0);
    signal we_mem       : std_logic;
    signal pc_mc, pc_cm : std_logic_vector(12 downto 0);

    --Internal variables used by the PIC control logic

    signal state                        : possible_states := iFetch;
    --The can_exec signal is for the current cycle, and since the alu outputs the can exec for the next cycle, it needs a single bit of memory.
    signal can_exec, can_exec_alu_old   : std_logic := '1';



begin
    running : process (clk) is
    begin
        if rising_edge(clk) then
            --Starting value declarations.
            we_wreg <= '0';
            we_mem <= '0';
            fetch <= '0';
            goto_bool <= '0';
            push <= '0';
            pop <= '0';

            if reset then 
                --Doing nothing to make sure that all of the other parts have time to reset properly
                state <= iFetch;
            else
                case state is
                    when iFetch =>
                        --Giving the decoder the op_code
                        to_decoder <= op_code;
                        state <= Mread;
                    when Mread =>
                        --Read from memory or the literal value
                        if re then
                            A_alu <= mem_out;
                        else
                            A_alu <= K;
                        end if;
                        --B is always from the W-register
                        B_alu <= W_out;
                        if can_exec then
                            alu_op <= operation;
                            --Chacking if we dont write to the memory and if we can write at all
                            if (we_mem_dec = '0') and ( no_write = '0') then
                                we_wreg <= '1';
                            end if;
                            --Write enable is assigned 
                            we_mem <= we_mem_dec;
                        elsif can_exec_alu_old = '0' then
                            --Semantics, since the spec defines that skips cause the next cycle to be executed as NOP, does functionally nothing.
                            alu_op <= NOP;
                        end if;
                        state <= Execute;   
                    when Execute =>
                        if can_exec_alu_old = '1' then
                            --Raising the correct flags for the different two cycle operations
                            case operation is
                                when CALL =>
                                    goto_bool <= '1';
                                    push <= '1';
                                when GOTO =>
                                    goto_bool <= '1';
                                when RETLW | RETRN =>
                                    --RETLW works, since it assigns the literal value on the first cycle, and on the next cycle it causes no_exec
                                    pop <= '1';                            
                                when others=>
                                    null;
                            end case;
                        end if;
                        --fetch is the PC chip enable, i.e. "fetch" the next PC value
                        fetch <= '1';
                        state <= Mwrite;
                    when Mwrite =>
                        --Mwrite mainly allows time for the memory writes, could be conditionally skipped but currently have no time
                        --Saving the current value of ALU can_exec
                        can_exec_alu_old <= can_exec_alu;
                        state <= iFetch;
                    when others =>
                        state <= iFetch;
                end case;
            end if;
        end if;
    end process;
    --While implementing the top bits might not be necessary since most programs are quite small, it will increase the accuracy of the PIC
    --Defining them separately is only done for clarity,
    addr_top_bits <= pc_cm(12 downto 11);
    --Expand 11 bits of literal address to 13 bits of actual program memory address
    goto_addr <= addr_top_bits & address;
    --Dummy output that can be seen in tests.
    result <= W_out;
    --program counter output
    pc <= pc_cm;
    --Combine both methods of requiring two clock cycles to execute an instruction.
    can_exec <= can_exec_pc and can_exec_alu_old;

    prog_cnt : program_counter
        port map   (goto_addr => goto_addr,
                    clk => clk,
                    reset => reset,
                    push => push,
                    pop => pop,
                    goto_bool => goto_bool,
                    fetch => fetch,
                    pc_in => pc_mc,
                    pc_out => pc_cm,
                    can_exec => can_exec_pc);

    alu : alu_easier
        port map   (A => A_alu,
                    B => B_alu,
                    operation => alu_op,
                    bit_select => bit_select,
                    status_in => status_mem_to_alu,
                    result => alu_result,
                    status => status_alu_to_mem,
                    can_exec => can_exec_alu);

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
                    pc_in => pc_cm,
                    pc_out => pc_mc,
                    status_in => status_alu_to_mem,
                    status_out => status_mem_to_alu,
                    data_out => mem_out,
                    PORTA => PORTA,
                    PORTB => PORTB);
                    
    dec : decoder 
        port map   (op_code => to_decoder,
                    operation => operation,
                    address => address,
                    K => K,
                    mem_address => mem_address,
                    bit_select => bit_select,
                    no_write => no_write,
                    we => we_mem_dec,
                    re => re);
end architecture;