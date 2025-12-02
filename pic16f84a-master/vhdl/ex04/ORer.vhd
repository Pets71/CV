-----------------
--OR function
-----------------
--A and B   : Inputs, 8 bits
--Q         : Output, 8 bits


library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity ORer is
    port (A, B          : in std_logic_vector (7 downto 0);
          Q             : out std_logic_vector (7 downto 0));
end entity ORer;

architecture rtl of ORer is
begin

    oring : process (A, B)
    begin
        Q <= A or B;
    end process;


end architecture;
