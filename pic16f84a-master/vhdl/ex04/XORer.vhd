-----------------
--XOR function
-----------------
--A and B   : Inputs, 8 bits
--Q         : Output, 8 bits

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity XORer is
    port (A, B  : in std_logic_vector (7 downto 0);
          Q     : out std_logic_vector (7 downto 0));
end entity XORer;

architecture rtl of XORer is
begin
    xoring : process (A, B)
    begin
        Q <= (A xor B);
    end process;
end architecture;


