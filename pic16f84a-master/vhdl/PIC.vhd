-----------------------------------------
--PIC with Hexfile reader test bench
-----------------------------------------

library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operation_package.all;
use work.read_intel_hex_pack.all;

entity PIC is
    --This defines the compiled assembly hexfile to be executed by the PIC
    CONSTANT in_hex_file : string := "/home/pkippo2/DigMic2/PIC16F84A/piklab/blinker.hex";
end entity PIC;



architecture behavioural of PIC is 
    signal op_code          : std_logic_vector(13 downto 0);
    signal pc               : std_logic_vector (12 downto 0);
    signal result           : std_logic_vector(7 downto 0);
    signal PORTA            : std_logic_vector(4 downto 0);
    signal PORTB            : std_logic_vector(7 downto 0);
    signal clk, reset       : std_logic;

        -- Declaration of the pic prototype
    component pic_cl is
        generic        (N           : positive := 2 ** 7);
        port           (op_code     : in std_logic_vector(13 downto 0);
                        clk         : in std_logic;
                        reset       : in std_logic;
                        result      : out std_logic_vector (7 downto 0);
                        pc          : out std_logic_vector (12 downto 0);
                        PORTA       : out std_logic_vector(4 downto 0);
                        PORTB       : out std_logic_vector(7 downto 0));
    end component;
begin

    simulation : process
        VARIABLE program_memory : program_array := (others => (others => '0'));
    begin
        --Initialisation
        read_ihex_file(in_hex_file, program_memory);
        op_code <= "00000000000000";
        clk <= '1';
        reset <= '1';
        wait for 1 fs;
        clk <= '0';
        wait for 1 fs;
        clk <= '1';
        reset <= '0';
        --Looping instructions until the PC reaches its maximum value.
        -- Make sure that the hexfile does not run in an infinite loop, so that the testbench terminates.
        running : while to_integer(unsigned(pc)) <= inst_mem_size - 1  loop
            op_code <= program_memory(to_integer(unsigned(pc)));
            clk <= not(clk);
            wait for 1 fs;
        end loop ; 
        wait;
    end process;
    

         pic_proto : pic_cl
            generic map    (N => 2**7)
            port map       (op_code => op_code,
                            clk => clk,
                            reset => reset,
                            result => result,
                            pc => pc,
                            PORTA => PORTA,
                            PORTB => PORTB);


end architecture behavioural;
