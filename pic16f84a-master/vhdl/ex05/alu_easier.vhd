
library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.operation_package.all;

entity alu_easier is
    port (A, B          : in std_logic_vector (7 downto 0);
          operation     : in op_type;
          bit_select    : in std_logic_vector (2 downto 0);
          status_in     : in std_logic_vector (2 downto 0);
          result        : out std_logic_vector (7 downto 0);
          status        : out std_logic_vector (2 downto 0));
end entity alu_easier;

architecture rtl of alu_easier is
    signal first_result            : std_logic_vector(7 downto 0);
begin

    working : process (all)

    procedure adding (A_add    : in std_logic_vector(7 downto 0);
                      B_add    : in std_logic_vector(7 downto 0);
                      CI_add   : in std_logic) is
    variable CarryOut : unsigned(8 downto 0);
    variable NibbleOut : unsigned(4 downto 0);
    begin
        CarryOut := unsigned('0' & A_add) + unsigned('0' & B_add) + std_ulogic(CI_add);
        NibbleOut := unsigned('0' & A_add(3 downto 0)) + unsigned('0' & B_add(3 downto 0)) + std_ulogic(CI_add);
        status(0) <= std_logic(CarryOut(8));
        status(1) <= std_logic(NibbleOut(4));
        status(2) <= std_logic(nor(CarryOut(7 downto 0)));
        result <= std_logic_vector(CarryOut(7 downto 0));
    end procedure;

    procedure XORing   (A_xor           : in std_logic_vector(7 downto 0);
                        B_xor           : in std_logic_vector(7 downto 0);
                        signal Q_xor    : out std_logic_vector(7 downto 0)) is
    begin
        status(2) <= nor(A_xor xor B_xor);
        Q_xor <= (A_xor xor B_xor);
    end procedure; 
    begin
        status <= status_in;
        first_result <= "00000000";
        case operation is
            when ADD =>
                adding(A, B, '0');
            when SUB =>
                XORing ( B, "11111111", first_result);
                adding ( A, first_result , '1');
            when INC =>
                status(0) <= '0';
                status(1) <= '0';
                adding ( A, "00000001", '0');
            when DEC =>
                status(0) <= '0';
                status(1) <= '0';    
                adding ( A, "11111110" , '1');
                when COM =>
                XORing ( A, "11111111", result);
            when XOP =>
                XORing ( A, B, result);
            when IOR =>
                status(2) <= nor(A or B);    
                result <= (A or B);
            when ANP =>
                status(2) <= nor(A and B);
                result <= (A and B);
            when RRF =>
                status(0) <= A(0);
                result <= std_logic_vector(shift_right(unsigned(A), 1));
                result(7) <= status_in(0);
            when RLF =>
                status(0) <= A(7);
                result <= std_logic_vector(shift_left(unsigned(A), 1));
                result(0) <= status_in(0);
            when BCF =>
                result <= A;
                result(to_integer(unsigned(bit_select))) <= '0';
            when BSF =>
                result <= A;
                result(to_integer(unsigned(bit_select))) <= '1';
            when SWP =>
                for i in 7 downto 4 loop
                    result(i) <= A(i-4);
                end loop;
                for i in 3 downto 0 loop
                    result(i) <= A(i+4);
                end loop;
            when MOV =>
                result <= A;
            when CLR =>
                result <= "00000000";
            when others =>
                null;
            end case;

    end process;

end architecture rtl;
