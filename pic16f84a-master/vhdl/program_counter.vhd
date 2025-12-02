----------------------------
--Program counter
---------------------------
--goto_addr         : The target jump address, 13 bits.
--clk               : Clock signal, operations are clocked to rising edge, 1 bit.
--reset             : Reset signal, resets memory to empty, 1 bit.
--push              : Whether or not the current value is pushed to the stack, 1 bit.
--pop               : Whether or not the top value of the stack is popped, 1 bit.
--goto_bool         : If a jump to some address is happening instead of normal operation.
--fetch             : If a new address is fetched, sort of a chip enable, 1 bit.
--pc_in             : Input of the current PC value, since it is stored in the registers, 13 bits.
--pc_out            : Output of the updated PC value, to be stored in the registers, 13 bits.
--can_exec          : If the next cycle should not be executed, since some instructions take 2 cycles to execute.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
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
end entity program_counter;

architecture rtl of program_counter is

    component stack is  
    port       (data_in     : in std_logic_vector(12 downto 0);
                clk         : in std_logic;
                reset       : in std_logic;
                we          : in std_logic;
                re          : in std_logic;
                data_out    : out std_logic_vector(12 downto 0);
                empty       : out std_logic);
    end component stack;

    --Internal connections to the stack
    signal to_stack, from_stack     : std_logic_vector(12 downto 0) := "0000000000000";
    signal we, re, empty            : std_logic := '0';

    --Internal variables

    --This memory element is needed so that we can check for writes into the PC memory address.
    signal pc_mem : std_logic_vector(12 downto 0) := "0000000000000";
    
    --Small state machine for the program counter
    --00    : Normal operation
    --01    : Empty cycle after popping the top of the stack.
    --10    : Jump to address
    --11    : Jump to address cycle after pushing the current one to the stack
    --The distinction between 10 and 11 is only done for debug purposes.
    signal state                    : std_logic_vector(1 downto 0) :="00";

begin
    synchronous_operation   : process (clk) is
    begin
        if rising_edge(clk) then
            we <= '0';
            re <= '0';
            if reset then
                pc_mem <= "0000000000000";
                state <= "00";
            elsif fetch then
                if state = "00" then
                    if goto_bool then
                        if push then
                            --Raising the push flag and 
                            to_stack <= pc_in;
                            we <= '1';
                            state <= "11";
                        else
                            state <= "10";
                        end if;
                        
                    elsif pop and not(empty) then
                        --Take in the value from the top of the stack and raise the pop flag.
                        pc_mem <= from_stack;
                        re <= '1';
                        state <= "01";
                    elsif pc_mem = pc_in then
                        --Normal incrementation
                        pc_mem <= std_logic_vector(unsigned(pc_in) + "0000000000001");
                    else
                        --Special case, when write happens to the memory address of the PC, it is not incremented at the end of that cycle.
                        --Checked using piklab.
                        pc_mem <= pc_in;
                    end if;
                else       
                    if state(1) = '1' then
                        --Change the PC to the desired address
                        pc_mem <= goto_addr;
                    end if;
                    --Reset to base state
                    state <= "00";
                end if;
            end if;
        end if;
    end process;

    --PC to be written to memory
    pc_out <= pc_mem;
    --Instructions can only be executed during the base state.
    can_exec <= '1' when state = "00" else '0';

    pc_stack : stack
    port map   (data_in => to_stack,
                clk => clk,
                reset => reset,
                we => we,
                re => re,
                data_out => from_stack,
                empty => empty);

end architecture;