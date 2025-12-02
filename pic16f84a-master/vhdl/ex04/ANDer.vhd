-----------------
--AND function
-----------------
--A and B   : Inputs, 8 bits
--Q         : Output, 8 bits

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity ANDer is
    port (A, B  : in std_logic_vector (7 downto 0);
          Q     : out std_logic_vector (7 downto 0));
end entity ANDer;

architecture rtl of ANDer is
begin
    anding : process (A, B)
    begin
        Q <= (A and B);
    end process;
end architecture;


