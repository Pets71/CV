-----------------------------------------
--ALU with input and output file test bench
-----------------------------------------

library ieee; 

use std.textio.all;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

use work.operation_package.all;

entity tb_ex04 is
end entity tb_ex04;

architecture behavioural of tb_ex04 is 
    signal A, B, result                     : std_logic_vector(7 downto 0);
    signal op                               : std_logic_vector(3 downto 0);
    signal status, status_in, bit_select    : std_logic_vector(2 downto 0);
    signal operation                        : op_type;

        -- Declaration of the alu
    component alu is
    port (A, B          : in std_logic_vector (7 downto 0);
          operation     : in op_type;
          bit_select    : in std_logic_vector (2 downto 0);
          status_in     : in std_logic_vector (2 downto 0);
          result        : out std_logic_vector (7 downto 0);
          status        : out std_logic_vector (2 downto 0));    
    end component;
begin

    simulation : process

        file input_file                 : text open read_mode is "../../vhdl/ex04/input.txt";
        file output_file                : text open write_mode is "../../vhdl/ex04/output.txt";
        variable input_line             : line;
        variable output_line            : line;
        variable command                : string (20 downto 1);

                -- Helper function to ease data type conversion

        function char_to_bit (char : in character) return std_logic is
        begin
            if char = '0' then
                return '0';
            else
                return '1';
            end if;
        end function;

    begin
        status_in <= "000";
        while not endfile(input_file) loop
            --Read line proccess and datatype conversion to std_logic_vector
            --Data is assumed to be formatted as such:
            --4 bit opcode
            --8 bits of A, which correlates to f / literal
            --8 bits of B, of which the last 3 also act as the bit select.
            --correlates to W 
            readline(input_file, input_line);
            read(input_line,command);
            for i in 16 downto 9 loop
                A(i-9) <= char_to_bit(command(i));
            end loop;
            
            for i in 8 downto 1 loop
                B(i-1) <= char_to_bit(command(i));
            end loop;

            for i in 20 downto 17 loop
                op(i-17) <= char_to_bit(command(i));
            end loop;


            --Given write delay
           
            wait for 10 ns;
            -- Write the outputs of the ALU

            write(output_line, result);
            write(output_line, status);
            writeline(output_file, output_line);
        end loop;
        wait;
    end process;
    
    --Process to transfer the last bits of B into the bit select signal.
    B_to_bit_select : process (B)
    begin
        for i in 2 downto 0 loop
            bit_select(i) <= B(i);
        end loop;
    end process;


    op_to_operation : process (op)
    begin
        case op is
            when "0111" =>
                operation <= ADD;
            when "0010" => 
                operation <= SUB;
            when "1010" =>
                operation <= INC;
            when "0011" =>
                operation <= DEC;
            when "1001" =>
                operation <= COM;
            when "0110" =>
                operation <= XOP;
            when "0001" =>
                operation <= IOR;           
            when "1101" =>
                operation <= ANP;
            when "0100" =>
                operation <= BCF;
            when "0101" =>
                operation <= BSF;
            when "1000" =>
                operation <= MOV;
            when "1110" =>
                operation <= SWP;
            when "1111" =>
                operation <= RLF;
            when "1011" =>
                operation <= RRF;
            when "0000" =>
                operation <= CLR;
            when others =>
                operation <= NOP;
        end case;
    end process;

         alu_used: alu
            port map    (A => A,
                         B => B,
                         operation => operation,
                         bit_select => bit_select,
                         status_in => status_in,
                         result => result,
                         status => status);


end architecture behavioural;
