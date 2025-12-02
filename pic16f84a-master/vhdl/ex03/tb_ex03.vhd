-----------------------------------------
--Adders with input and output file test bench
-----------------------------------------

library ieee; 

use std.textio.all;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity tb_ex03 is
    generic(N : positive := 8);
end entity tb_ex03;

architecture behavioural of tb_ex03 is 
    signal CI, CO_pr, CO_ri     : std_logic;
    signal A, B, S_pr, S_ri     : std_logic_vector(N - 1 downto 0);

        -- Declaration of our process adder.
    component N_bit_adder is
    generic (N : positive);
    port    (CI             : in std_logic;
             A, B           : in std_logic_vector(N - 1 downto 0);
             CO             : out std_logic;             
             S              : out std_logic_vector(N - 1 downto 0));
    end component;

        -- Declaration of our generated adder
    component ripple_adder is
    generic (N : positive);
    port    (CI             : in std_logic;
             A, B           : in std_logic_vector(N - 1 downto 0);
             CO             : out std_logic;             
             S              : out std_logic_vector(N - 1 downto 0));
    end component;
begin

    simulation : process
        file input_file                 : text open read_mode is "../../vhdl/ex03/input.csv";
        file output_file_process        : text open write_mode is "../../vhdl/ex03/output_pr.csv";
        file output_file_ripple         : text open write_mode is "../../vhdl/ex03/output_ri.csv";
        variable input_line             : line;
        variable output_line_process    : line;
        variable output_line_ripple     : line;
        variable A_int, B_int           : integer;
        variable comma                  : character;
    begin
        CI <= '0';
        -- Carry in is set to 0'so that it doesn't interfere with the calculations
        while not endfile(input_file) loop
            -- Read line proccess and datatype conversion to std_logic_vector
            readline(input_file, input_line);
            read(input_line,A_int);
            A <= std_logic_vector(to_unsigned(A_int, A'length));
            read(input_line,comma);
            read(input_line,B_int);
            B <= std_logic_vector(to_unsigned(B_int, B'length));
            
            wait for 10 ns;
            -- Write the outputs of the process adder 
            write (output_line_process, to_integer(unsigned(S_pr)));
            write (output_line_process, comma);
            write (output_line_process, CO_pr);
            writeline(output_file_process, output_line_process);
            -- Write the outputs of the generated adder
            write (output_line_ripple, to_integer(unsigned(S_ri)));
            write (output_line_ripple, comma);
            write (output_line_ripple, CO_ri);
            writeline(output_file_ripple, output_line_ripple);
        end loop;
        wait;
    end process;
        -- Connections to the process adder.
        adder_process : N_bit_adder
            generic map (N => N)
            port map    (A => A,
                         B => B,
                         S => S_pr,
                         CI => CI,
                         CO => CO_pr);

        adder_generated : ripple_adder
            generic map (N => N)
            port map    (A => A,
                         B => B,
                         S => S_ri,
                         CI => CI,
                         CO => CO_ri);

end architecture behavioural;
