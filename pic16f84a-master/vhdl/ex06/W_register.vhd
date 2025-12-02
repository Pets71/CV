----------------------------
--W register
----------------------------
--data_in   : Input, data to be written, 1 byte (8 bits).
--clk       : Clock signal, writes are clocked to risedge 1 bit.
--reset     : Reset signal, resets memory to empty, 1 bit.
--we        : Write enable, allows a write operation to occur, 1 bit. 
--data_out  : Output, the data being requested, 1 byte (8 bits);

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity W_register is
    port       (data_in     : in std_logic_vector(7 downto 0);
                clk         : in std_logic;
                reset       : in std_logic;
                we          : in std_logic;
                data_out    : out std_logic_vector(7 downto 0));
end entity W_register;

architecture rtl of W_register is
    signal memory : std_logic_vector(7 downto 0);
begin
    synchronous_operation : process (clk) is
    begin
        if rising_edge(clk) then
            if reset then 
                memory <= "00000000";
            else
                if we then
                    memory <= data_in;
                end if;
            end if;
        end if;
    end process;
    data_out <= memory;


end architecture rtl;