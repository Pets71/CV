---------------------------
--Full adder
---------------------------
--A and B   : Data inputs to be added, N bits
--CI        : Carry in, 1 bit
--S         : Output sum, N bits
--CO        : Carry out, 1 bit
---------------------------
library ieee; 

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity N_bit_adder is
    generic (N : positive);
    port    (A, B       : in std_logic_vector(N-1 downto 0);
             CI         : in std_logic;
             S          : out std_logic_vector(N-1 downto 0);
             CO         : out std_logic);
end entity N_bit_adder;

architecture behavioural of N_bit_adder is
    signal COS : unsigned (N downto 0);
begin
    calculating_array : process (A, B, CI)
    begin
        COS <= ('0' & unsigned(A)) + ('0' & unsigned(B)) + std_ulogic(CI);
    end process;

    array_to_vals : process (COS)
    begin
        CO <= std_logic(COS(N)); 
        for i in N - 1 downto 0 loop
            S(i) <= std_logic(COS(i));
        end loop;
    end process;
end architecture behavioural;
