--------------------------------
--ALU for PIC microcontroller
--------------------------------
--A and B       : Data inputs, 8 bits.
--operation     : Given instruction for the ALU, op_type from operation_package.
--bit_select    : Bit selection for bit operations, 3 bits.
--status_in     : Status from the previous cycle, 3 bits.
--can_exec      : Whether or not the next instruction can be executed or is NOP, 1 bit.
--result        : Result of the operation, 8 bits.
--status        : Status in the current cycle, 3 bits.



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operation_package.all;

entity alu_easier is
    port (A, B          : in std_logic_vector (7 downto 0);
          operation     : in op_type;
          bit_select    : in std_logic_vector (2 downto 0);
          status_in     : in std_logic_vector (2 downto 0);
          can_exec      : out std_logic;
          result        : out std_logic_vector (7 downto 0);
          status        : out std_logic_vector (2 downto 0));
end entity alu_easier;

architecture rtl of alu_easier is
    --Used when one operation requires a midway value.
    signal first_result            : std_logic_vector(7 downto 0);
begin

    working : process (all)

    --Procedure that does simple additions
    procedure adding (A_add    : in std_logic_vector(7 downto 0);
                      B_add    : in std_logic_vector(7 downto 0);
                      CI_add   : in std_logic;
                      op_add   : in op_type) is
    --Its internal variables
    variable CarryOut : unsigned(8 downto 0);
    variable NibbleOut : unsigned(4 downto 0);

    begin
        --We have to do the addition twice to see if a nibble carry (carry from bit 3 to 4) happens. (Bits go from 0 to 7)
        CarryOut := unsigned('0' & A_add) + unsigned('0' & B_add) + std_ulogic(CI_add);
        NibbleOut := unsigned('0' & A_add(3 downto 0)) + unsigned('0' & B_add(3 downto 0)) + std_ulogic(CI_add);
        case(op_add) is
            -- Either update status register, or skip next if zero, depending on the instruction.
            when INCFSZ | DECFSZ =>
                can_exec <= not(std_logic(nor(CarryOut(7 downto 0))));
            when others =>
                --Status register is Carry, Nibble carry and then Zero flags, 0-2
                status(0) <= std_logic(CarryOut(8));
                status(1) <= std_logic(NibbleOut(4));
                status(2) <= std_logic(nor(CarryOut(7 downto 0)));
        end case ;
        --This value is always written to the output of the ALU
        result <= std_logic_vector(CarryOut(7 downto 0));
    end procedure;


    --Procedure used for XORing

    procedure XORing   (A_xor           : in std_logic_vector(7 downto 0);
                        B_xor           : in std_logic_vector(7 downto 0);
                        signal Q_xor    : out std_logic_vector(7 downto 0)) is
    begin
        status(2) <= nor(A_xor xor B_xor);
        --Since in some cases XOR output is used internally, we use a special variable for it
        Q_xor <= (A_xor xor B_xor);
    end procedure; 
    begin
        --Starting values
        status <= status_in;
        first_result <= "00000000";
        can_exec <= '1';
        case operation is
            --A large case operand is used, with them matching the operation, i.e. increment when INCF and so on.
            --More info on operations and such can be seen in the PIC spec sheet.
            when ADDWF | ADDLW =>
                adding ( A, B, '0', operation);
            when SUBWF | SUBLW =>
                --Substraction can be achieved by XORing the second term with all ones, and adding them together + 1
                XORing ( A, "11111111", first_result);
                adding ( B, first_result , '1', operation);
            when INCF  | INCFSZ =>
                status(0) <= '0';
                status(1) <= '0';
                adding ( A, "00000001", '0', operation);
            when DECF |DECFSZ =>
                status(0) <= '0';
                status(1) <= '0';    
                adding ( A, "11111110" , '1', operation);
                when COMF =>
                XORing ( A, "11111111", result);
            when XORWF  =>
                XORing ( A, B, result);
            when IORWF | IORLW=>
                status(2) <= nor(A or B);    
                result <= (A or B);
            when ANDWF | ANDLW =>
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
            when SWAPF =>
                for i in 7 downto 4 loop
                    result(i) <= A(i-4);
                end loop;
                for i in 3 downto 0 loop
                    result(i) <= A(i+4);
                end loop;
            when MOVF | MOVLW | RETLW =>
                --All moves and writes are done through the ALU for simplicitys sake
                result <= A;
            when MOVWF =>
                --The reason for this case mirroring B instead of A is that B is hardwired to always be connected to the W-register
                result <= B;
            when CLRF | CLRW =>
                result <= "00000000";
            when BTFSC =>
                --Skips next based on condition
                --While not needed by the original spec, added them to use the blinker assembly code.
                if A(to_integer(unsigned(bit_select))) = '0' then
                    can_exec <= '0';
                else
                    can_exec <= '1';
                end if;
                result <= "00000000";
            when BTFSS =>
                if A(to_integer(unsigned(bit_select))) = '1' then
                    can_exec <= '0';
                else
                    can_exec <= '1';
                end if;
                result <= "00000000";
            when others =>
                result <= "00000000";
            end case;

    end process;

end architecture rtl;
