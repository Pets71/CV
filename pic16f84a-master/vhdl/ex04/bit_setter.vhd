-----------------------
--Sets a bit of a byte
-----------------------
--A             : input value, 8 bits
--bit_select    : input byte selection, 3 bits 
--B             : input byte value, 1 bit
--Q             : output, 8 bits
library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity bit_setter is
    port (A             : in std_logic_vector (7 downto 0);
          bit_select    : in std_logic_vector (2 downto 0);
          B             : in std_logic;
          Q             : out std_logic_vector (7 downto 0));
end entity bit_setter;

architecture rtl of bit_setter is
begin
    swapping : process (A, B, bit_select)
    begin
        Q <= A;
        Q(to_integer(unsigned(bit_select))) <= B;
    end process;
end architecture rtl;
