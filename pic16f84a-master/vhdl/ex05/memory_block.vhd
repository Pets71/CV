----------------------------
--Memory block
----------------------------
--N         : Parameter, the number of bytes in the block.
--address   : Input address, the address of the data, 7 bits.
--data_in   : Input, data to be written, 1 byte (8 bits).
--clk       : Clock signal, operations are clocked to risedge 1 bit.
--reset     : Reset signal, resets memory to empty, 1 bit.
--we        : Write enable, allows a write operation to occur, 1 bit. 
--re        : Read enable, allows a read operation to occur, 1 bit. 
--data_out  : Output, the data being requested, 1 byte (8 bits);

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity memory_block is
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
end entity memory_block;

architecture rtl of memory_block is
    type memory_array is array (0 to N - 1) of std_logic_vector(7 downto 0);
    signal memory : memory_array;
begin
    synchronous_operation : process (clk) is
    begin
        if rising_edge(clk) then
            if reset then 
                memory <= (others => "00000000");
                data_out <= "00000000";
            else
                if  not ((address = "0000011") and (we = '1')) then
                    memory(3)(2 downto 0) <= status_in;
                end if;
                if we then
                    memory(to_integer(unsigned(address))) <= data_in;
                elsif re then
                    data_out <= memory(to_integer(unsigned(address)));
                end if;
            end if;
        end if;
    end process;

    status_out_operation : process (memory(3)(2 downto 0)) is
    begin
        status_out <= memory(3)(2 downto 0);
    end process;
    
end architecture rtl;