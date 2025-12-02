---------------------------
--Full adder
---------------------------
--A and B   : Data inputs to be added, 1 bit
--CI        : Carry in, 1 bit
--S         : Output sum, 1 bit
--CO        : Carry out, 1 bit
---------------------------
library ieee; 

use ieee.std_logic_1164.all;

entity full_adder is
    port   (A, B, CI    : in std_logic;
            S, CO       : out std_logic); 
end entity full_adder;

architecture rtl of full_adder is
begin
    calculating : process (A, B, CI)
    begin
        S <= A xor B xor CI;
        CO <= (A and B) or (A and CI) or (CI and B); 
    end process;
end architecture rtl;
