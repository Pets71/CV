-----------------------------------------
--Multiplexer with output file test bench
-----------------------------------------

library ieee; 

use std.textio.all;

entity tb_ex02 is
end entity tb_ex02;

architecture behavioural of tb_ex02 is 
    signal S        : bit;
    signal A, B, Q  : bit_vector(7 downto 0);

    component multiplexer is 
    port   (S       : in bit;
            A, B    : in bit_vector(7 DOWNTO 0);
            Q       : out bit_vector(7 DOWNTO 0));
    end component;
begin

    read_write_simulation: process
        file input_file         : text open read_mode is "../../vhdl/ex02/input.txt";
        file output_file        : text open write_mode is "../../vhdl/ex02/output.txt";
        -- Not sure if these locations are correct for the file, btu can be changed later. 
        variable input_line     : line;
        variable output_line    : line;
        variable stimulus_vect  : string (17 downto 1);

        -- Helper function to ease data type conversion

        function char_to_bit (char : in character) return bit is
        begin
            if char = '0' then
                return '0';
            else
                return '1';
            end if;
        end function;

    begin
        -- Run until endfile
        while not endfile(input_file) loop
            readline(input_file, input_line);
            read(input_line, stimulus_vect);
            --Assuming that the file is organized so that it has 
            --8 chars of A
            --8 chars of B
            --1 char of S

            for i in 17 downto 10 loop
                A(i-10) <= char_to_bit(stimulus_vect(i));
            end loop;
            
            for i in 9 downto 2 loop
                B(i-2) <= char_to_bit(stimulus_vect(i));
            end loop;

            S <= char_to_bit(stimulus_vect(1));
            --Given write delay
            wait for 10 ns;

            --Then we write the output variables
            write(output_line, Q);
            writeline(output_file, output_line);

        end loop;
        wait; 
        -- Stop simulation (Important)
    end process;
        mux : multiplexer
            port map   (A => A,
                        B => B,
                        S => S,
                        Q => Q);

end architecture behavioural;
