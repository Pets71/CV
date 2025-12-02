-----------------------
--Swaps nibbles of byte
-----------------------
--A     : input, 8 bits
--Q     : output, 8 bits

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity swapper is 
    port (A     : in std_logic_vector (7 downto 0);
          Q     : out std_logic_vector (7 downto 0));
end entity swapper;

architecture rtl of swapper is
begin
    swapping : process (A)
    begin
        for i in 7 downto 4 loop
            Q(i) <= A(i-4);
        end loop;
        for i in 3 downto 0 loop
            Q(i) <= A(i+4);
        end loop;
    end process;
end architecture rtl;
