--------------------------------
--Decoder for PIC instructions
--------------------------------
--op_code       : Opcode, which is translated to op_code and additional parameters, 14 bits.
--operation     : Instruction for the ALU, op_type from operation_package.
--address       : Program memory address to be accessed, only the 11 lowest bits.
--K             : Literal data value to be used in the operation, 8 bits.
--mem_adress    : Data memory address to be used in the operation, either for a read or a write, 7 bits.
--bit_select    : Bit selection for bit operations, 3 bits.
--no_write      : If the operation involves no writes at all, 1 bit.
--we            : Write enable for the data memory, otherwise write is assumed to be to the W-register (no_write overrides this), 1 bit.
--re            : Read enable for the data memory, otherwise reads the other input from literal K, 1 bit.

--Since not all of the op_codes have all of the outputs parameteres, in these cases the unused outputs have the value 0; 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operation_package.all;

entity decoder is 
    port(op_code        : in std_logic_vector(13 downto 0);
         operation      : out op_type;
         address        : out std_logic_vector(10 downto 0);
         K              : out std_logic_vector(7 downto 0);
         mem_address    : out std_logic_vector(6 downto 0);
         bit_select     : out std_logic_vector(2 downto 0);
         no_write       : out std_logic;
         we             : out std_logic;
         re             : out std_logic);
end entity decoder;

architecture rtl of decoder is
begin
    decoding : process(op_code)
    begin
        --Starting values for all of the fields
        address <= "00000000000";
        K <= "00000000";
        mem_address <= "0000000";
        bit_select <= "000";
        we <= '0';
        re <= '0';
        no_write <= '0';
        --ERR is a special operator, which signifies that something went wrong in the decoding process
        operation <= ERR;
        case op_code(13 downto 12) is
            --All of the instructions are grouped together based on some bits and common variables in them.
            when "00" =>
                --All 00 beginning opcodes read from the memory
                mem_address <= op_code(6 downto 0);
                re <= '1';
                --Bit 7 is very commonly used to signify whether or not an opcode writes to W-register or to the memory address accessed
                we <= op_code(7);
                case op_code(11 downto 8) is
                    when "0000" =>
                        if op_code(7) = '1' then
                            operation <= MOVWF;
                            re <= '0';
                        elsif op_code(4 downto 0) = "00000" then
                            operation <= NOP;
                            no_write <= '1';
                        else
                            no_write <= '1';
                            case op_code(6 downto 0) is
                                --All of the following operations are not implemented, but are included in the decoder for future compatibility.
                                when "1100100" =>
                                    operation <= CLRWDT;
                                when "0001001" =>
                                    operation <= RETFIE;
                                when "0001000" =>
                                    --RETURN is also an operation in VHDL, so it is shortened in the package.
                                    operation <= RETRN; 
                                when "1100011" =>
                                    operation <= SLEEP;
                                when others =>
                                    operation <= ERR;
                            end case;
                        end if;
                    when "0111" =>
                        operation <= ADDWF;
                    when "0101" =>
                        operation <= ANDWF;
                    when "0001" =>
                        --While the different functions of these two ops are handled by the we flag, for clarity both are added.
                        if op_code(7) = '1' then
                            operation <= CLRF;
                        else
                            operation <= CLRW;
                        end if;
                    when "1001" =>
                        operation <= COMF;
                    when "0011" =>
                        operation <= DECF;
                    when "1011" =>
                        operation <=DECFSZ;
                    when "1010" =>
                        operation <= INCF;
                    when "1111" =>
                        operation <= INCFSZ;
                    when "0100" =>
                        operation <=IORWF;
                    when "1000" =>
                        operation <= MOVF;
                    when "1101" =>
                        operation <= RLF;
                    when "1100" =>
                        operation <= RRF;
                    when "0010" =>
                        operation <=SUBWF;
                    when "1110" =>
                        operation <=SWAPF;
                    when "0110" =>
                        operation <= XORWF;
                    when others =>
                        operation <= ERR;
                end case;   
            when "01" =>
                --All opcodes beginning with 01 read from the memory, and perform some single bit operation.
                bit_select <= op_code(9 downto 7);
                mem_address <= op_code(6 downto 0);
                re <= '1';
                case op_code(11 downto 10) is
                    when "00" =>
                        operation <= BCF;
                        we <= '1';
                    when "01" =>
                        operation <= BSF;
                        we <= '1';
                    when "10" =>
                        operation <= BTFSC;
                        --One of the few operators that doesn't write to any register
                        no_write <= '1';
                    when "11" =>
                        operation <= BTFSS;
                        --One of the few operators that doesn't write to any register
                        no_write <= '1';
                    when others =>
                        operation <= ERR;
                end case;
            when "10" =>
                --The two opcodes beginning with 10 dont write, and move the PC to a different address.
                address <= op_code(10 downto 0);
                no_write <= '1';
                if op_code(11) then
                    operation <= GOTO;
                else
                    operation <= CALL;
                end if;
            when "11" =>
                --Operations beginning with 11 all use the literal K in their operations.
                K <= op_code(7 downto 0);
                case op_code(11 downto 10) is
                    when "11" =>
                        if op_code(9) then
                            operation <= ADDLW;
                        else
                            operation <= SUBLW;
                        end if;    
                    when "10" =>
                        case op_code(9 downto 8) is
                            when "01" =>
                                operation <= ANDLW;
                            when "00" =>
                                operation <= IORLW;
                            when "10" =>
                                operation <= XORLW;
                            when others =>
                                operation <= ERR;
                        end case;
                    when "00" =>
                        operation <= MOVLW;
                    when "01" =>
                        operation <= RETLW;
                    when others =>
                        operation <= ERR;
                end case;
            when others =>
                operation <= ERR;
        end case;
        --Simple warning for the program writer that they are writing in the status register
        assert not ((address = "0000011") and (we = '1'))
            report "Writing to status register"
            severity warning;
        --Error to be seen that the decoding process has somehow failed, or an incompatible opcode was given.
        assert operation /= ERR
            report "ERROR IN READING OPCODE"
            severity error;
    end process;
end architecture;