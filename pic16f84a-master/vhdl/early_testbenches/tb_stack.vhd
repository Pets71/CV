-----------------------------------------
--ALU with input and output file test bench
-----------------------------------------

library ieee;
use std.textio.all;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity tb_stack is
end entity tb_stack;

architecture behavioural of tb_stack is 
    signal data_in, data_out                : std_logic_vector(12 downto 0);
    signal clk, reset, we, re, empty        : std_logic;

        -- Declaration of the stack prototype
        component stack is
            port       (data_in     : in std_logic_vector(12 downto 0);
                        clk         : in std_logic;
                        reset       : in std_logic;
                        we          : in std_logic;
                        re          : in std_logic;
                        data_out    : out std_logic_vector(12 downto 0);
                        empty       : out std_logic);
        end component stack;
begin



    simulation : process
    begin
        clk <= '0';
        reset <= '0';
        re <= '0';
        we <= '0';
        data_in <= "0000000000000";
        wait for 5 ns;
        clk <= '1';
        reset <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '0';
        data_in <= "0000000000001";
        we <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000000000011";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000000000111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000000001111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000000011111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000000111111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000001111111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000011111111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0000111111111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        data_in <= "0001111111111";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        we <= '0';
        re <= '1';
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
        we <= '1';
        re <= '0';
        data_in <= "0101010101010";
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        we <= '0';
        re <= '1';
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
    

         stack_DUT : stack
            
            port map   (data_in => data_in,
                        clk => clk,
                        reset => reset,
                        we => we,
                        re => re,
                        data_out => data_out,
                        empty => empty);


end architecture behavioural;
