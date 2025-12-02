-------------------------
--Bit shifter
-------------------------
--A     : Input value beign shifted, 8 bits
--CI    : Input carry in value, 1 bit
--dir   : Input direction of shift, 1 = right, 0 = left, 1 bit
--Q     : Output value after shift, 8 bits
--CO    : Output carry, bit moved out during shift, 1 bit

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    port(A          : in std_logic_vector (7 downto 0);
         CI, dir    : in std_logic;
         Q          : out std_logic_vector (7 downto 0);
         CO         : out std_logic);
end entity;

architecture rtl of shifter is
begin 
    shifting : process (A, CI, dir)
    begin
        if dir then 
            CO <= A(0);
            Q <= std_logic_vector(shift_right(unsigned(A), 1));
            Q(7) <= CI;
        else 
            CO <= A(7);
            Q <= std_logic_vector(shift_left(unsigned(A), 1));
            Q(0) <= CI;
        end if;
    end process;
end architecture rtl;
