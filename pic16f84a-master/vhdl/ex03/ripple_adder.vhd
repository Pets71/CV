---------------------------
--Ripple adder
---------------------------
--N         : Width of the adder
--A and B   : Data inputs to be added, N bits
--CI        : Carry in, 1 bit
--S         : Output sum, N bits
--CO        : Carry out, 1 bit
---------------------------

library ieee; 

use ieee.std_logic_1164.all;

entity ripple_adder is
    generic (N : positive);
    port    (A, B       : in std_logic_vector(N-1 downto 0);
             CI         : in std_logic;
             S          : out std_logic_vector(N-1 downto 0);
             CO         : out std_logic);
end entity ripple_adder;

architecture rtl of ripple_adder is
    signal CIO          : std_logic_vector(N - 2 downto 0);
    component full_adder is
    port   (A, B, CI    : in std_logic;
            S, CO       : out std_logic); 
    end component;
begin

    first_adder : component full_adder
        port map   (A => A(0),
                    B => B(0),
                    CI => CI,
                    S => S(0),
                    CO => CIO(0));

    construction : for i in 1 to N - 2 generate
    begin
            Nth_adder : component full_adder
            port map   (A => A(i),
                        B => B(i),
                        CI => CIO(i-1),
                        S => S(i),
                        CO => CIO(i));
    end generate;
    
    last_adder : component full_adder
        port map   (A => A(N-1),
                    B => B(N-1),
                    CI => CIO(N-2),
                    S => S(N-1),
                    CO => CO);

end architecture rtl;

