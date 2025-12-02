--Module for decoding instructions
--Control logic is handled in pic-module.

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
         we             : out std_logic;
         re             : out std_logic);
end entity decoder;

architecture rtl of decoder is
begin
    decoding : process(op_code)
    begin
        address <= "00000000000";
        K <= "00000000";
        mem_address <= "0000000";
        bit_select <= "000";
        we <= '0';
        re <= '0';
        operation <= ERR;
        case op_code(13 downto 12) is
            when "00" =>
                mem_address <= op_code(6 downto 0);
                re <= '1';
                we <= op_code(7);
                case op_code(11 downto 8) is
                    when "0000" =>
                        if op_code(7) = '1' then
                            operation <= MOVWF;
                            re <= '0';
                        elsif op_code(4 downto 0) = "00000" then
                            operation <= NOP;
                        else
                            case op_code(6 downto 0) is
                                when "1100100" =>
                                    operation <= CLRWDT;
                                when "0001001" =>
                                    operation <= RETFIE;
                                when "0001000" =>
                                    operation <= RETRN; --RETURN is also an operation in VHDL, so it is shortened in the _.
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
                    when "11" =>
                        operation <= BTFSS;
                    when others =>
                        operation <= ERR;
                end case;
            when "10" =>
                address <= op_code(10 downto 0);
                if op_code(11) then
                    operation <= GOTO;
                else
                    operation <= CALL;
                end if;
            when "11" =>
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
        assert not ((address = "0000011") and (we = '1'))
            report "Writing to status register"
            severity warning;
        assert operation /= ERR
            report "ERROR IN READING OPCODE"
            severity error;
    end process;
end architecture;