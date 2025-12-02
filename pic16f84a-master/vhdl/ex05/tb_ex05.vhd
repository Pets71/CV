-----------------------------------------
--ALU with input and output file test bench
-----------------------------------------

library ieee; 

use std.textio.all;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.operation_package.all;

entity tb_ex05 is
end entity tb_ex05;

architecture behavioural of tb_ex05 is 
    signal A, B, result                     : std_logic_vector(7 downto 0);
    signal address                          : std_logic_vector(6 downto 0);
    signal bit_select                       : std_logic_vector(2 downto 0);
    signal clk, reset, we_mem, re_mem       : std_logic;
    signal operation                        : op_type;

        -- Declaration of the pic prototype
    component pic is
        generic        (N           : positive := 2 ** 7);
        port           (A, B        : in std_logic_vector (7 downto 0);
                        operation   : in op_type;
                        bit_select  : in std_logic_vector (2 downto 0);
                        address     : in std_logic_vector(6 downto 0);
                        clk         : in std_logic;
                        reset       : in std_logic;
                        we_mem      : in std_logic;
                        re_mem      : in std_logic;
                        result      : out std_logic_vector (7 downto 0));
    end component;
begin



    simulation : process
    begin
--Very manual simulation, but it allows us to easily test the functions of the memory cell.
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '1';

        wait for 5 ns;
--Normal additons still work
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '0';
        operation <= ADD;
        we_mem <= '0';
        re_mem <= '0';
        A <= "00001000";
        B <= "00001000";
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
        reset <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;

        clk <= '1';
        reset <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        address <= "1000101";
        we_mem <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        re_mem <= '1';
        we_mem <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        reset <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        address <= "0000011";
        A <= "00000000";
        B <= "11111111";
        we_mem <= '1';
        re_mem <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        re_mem <= '1';
        we_mem <= '0';
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
        reset <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        operation <= MOV;
        re_mem <= '0';
        we_mem <= '1';
        A <= "11111111";
        B <= "11111111";
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
            port map       (A => A,
                            B => B,
                            operation => operation,
                            bit_select => bit_select,
                            address => address,
                            clk => clk,
                            reset => reset,
                            we_mem => we_mem,
                            re_mem => re_mem,
                            result => result);


end architecture behavioural;
