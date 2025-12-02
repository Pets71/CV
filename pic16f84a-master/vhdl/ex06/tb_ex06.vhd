-----------------------------------------
--ALU with input and output file test bench
-----------------------------------------

library ieee; 

use std.textio.all;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.operation_package.all;

entity tb_ex06 is
end entity tb_ex06;

architecture behavioural of tb_ex06 is 
    signal op_code          : std_logic_vector(13 downto 0);
    signal result           : std_logic_vector(7 downto 0);
    signal clk, reset       : std_logic;

        -- Declaration of the pic prototype
    component pic is
        generic        (N           : positive := 2 ** 7);
        port           (op_code     : in std_logic_vector(13 downto 0);
                        clk         : in std_logic;
                        reset       : in std_logic;
                        result      : out std_logic_vector (7 downto 0));
    end component;
begin



    simulation : process
    begin
        op_code <= "00000000000000";
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '0';
        op_code <= "11000000110011";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        op_code <= "00000010010000";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        op_code <= "11000000110101";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        op_code <= "00011100010000";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        op_code <= "00000010000011";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait;
    end process;
    

         pic_proto : pic
            generic map    (N => 2**7)
            port map       (op_code => op_code,
                            clk => clk,
                            reset => reset,
                            result => result);


end architecture behavioural;
