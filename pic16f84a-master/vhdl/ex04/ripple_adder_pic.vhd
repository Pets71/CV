---------------------------
--Ripple adder for PIC
---------------------------
--A and B   : Data inputs to be added, 8 bits
--CI        : Carry in, 1 bit
--S         : Output sum, 8 bits
--C         : Carry out, 1 bit
--DC	    : Digit carry, 1 bit
---------------------------

library ieee; 

use ieee.std_logic_1164.all;

entity ripple_adder_pic is
    port    (A, B       : in std_logic_vector(7 downto 0);
             CI         : in std_logic;
             S          : out std_logic_vector(7 downto 0);
             C, DC      : out std_logic);
end entity ripple_adder_pic;

architecture rtl of ripple_adder_pic is
    signal CIO          : std_logic_vector(6 downto 0);
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

    construction : for i in 1 to 6 generate
    begin
            Nth_adder : component full_adder
            port map   (A => A(i),
                        B => B(i),
                        CI => CIO(i-1),
                        S => S(i),
                        CO => CIO(i));
    end generate;
    
    last_adder : component full_adder
        port map   (A => A(7),
                    B => B(7),
                    CI => CIO(6),
                    S => S(7),
                    CO => C);

    digit_carry : process (CIO(3))
    begin
	    DC <= CIO(3);
    end process;

end architecture rtl;

