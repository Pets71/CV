----------------------------
--Stack
----------------------------
--data_in   : Input, data to be written, 13 bits.
--clk       : Clock signal, operations are clocked to rising edge, 1 bit.
--reset     : Reset signal, resets memory to empty, 1 bit.
--we        : Write enable, allows pushing to the stack, 1 bit. 
--re        : Read enable, allows popping from the stack, 1 bit. 
--data_out  : Output, the data being requested, 13 bits.
--empty     : Stack empty signal, 1 bit.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack is
    port       (data_in     : in std_logic_vector(12 downto 0);
                clk         : in std_logic;
                reset       : in std_logic;
                we          : in std_logic;
                re          : in std_logic;
                data_out    : out std_logic_vector(12 downto 0);
                empty       : out std_logic);
end entity stack;

architecture rtl of stack is

    --Internal variables

    type memory_array is array (0 to 7) of std_logic_vector(12 downto 0);
    signal memory       : memory_array := (others => "0000000000000");
    signal addr         : integer := -1;
    signal amount       : integer := 0;
    --This is also stored internally so that we can prevent pops when empty.
    signal empty_stack  : std_logic;
    
begin
    synchronous_operation   : process (clk) is
    begin
        if rising_edge(clk) then
            if reset then 
                --Reset values of the stack
                memory <= (others => "0000000000000");
                addr <= -1;
                amount <= 0;
            else
                if we then
                    --Add a value to the stack
                    if addr = 7 then
                        --Looparound
                        memory(0) <= data_in;
                        addr <= 0;
                    else
                        memory(addr + 1) <= data_in;
                        addr <= addr + 1;
                    end if;
                    --Increment amount only if not full
                    --While the address changes and the value is written, the stack can still only hold 8 values.
                    if amount /= 8 then
                        amount <= amount + 1;
                    end if;
                end if;
                if re and not(empty_stack) then
                    --We dont need to remove the values, since they will only be accessible if something is written to them.
                    amount <= amount - 1;
                    if addr = 0 then
                        --Looparound
                        addr <= 7;
                    else
                        addr <= addr - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --Raise the empty flag
    empty_stack <= '1' when amount <= 0 else '0';
    --We always have an output, and since in the case when it is empty the address is -1, we need to handle that.
    data_out <= memory(addr) when addr >= 0 else memory(0);
    empty <= empty_stack;

end architecture rtl;