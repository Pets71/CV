----------------------------
--Data memory
----------------------------
--N                 : Parameter, the number of bytes in memory.
--address           : Input address, the address of the data, 7 bits.
--data_in           : Input, data to be written, 1 byte (8 bits).
--clk               : Clock signal, operations are clocked to risedge 1 bit.
--reset             : Reset signal, resets memory to empty, 1 bit.
--we                : Write enable, allows a write operation to occur, 1 bit. 
--status_in         : Status from the current cycle, 3 bits.
--pc_in             : Input of the updated PC value, to be stored, 13 bits.
--pc_out            : Output of the current value of the PC, 13 bits.
--status_out        : Status in the register, 3 bits.
--data_out          : Output, the data being requested, 1 byte (8 bits);
--PORTA and PORTB   : Outputs from predefined register locations, which act as "ports", 5 and 8 bits respectively.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    generic    (N           : positive);
    port       (address     : in std_logic_vector(6 downto 0);
                data_in     : in std_logic_vector(7 downto 0);
                clk         : in std_logic;
                reset       : in std_logic;
                we          : in std_logic;
                status_in   : in std_logic_vector(2 downto 0);
                pc_in       : in std_logic_vector(12 downto 0);
                pc_out      : out std_logic_vector(12 downto 0);
                status_out  : out std_logic_vector(2 downto 0);
                data_out    : out std_logic_vector(7 downto 0);
                PORTA       : out std_logic_vector(4 downto 0);
                PORTB       : out std_logic_vector(7 downto 0));
end entity data_memory;

architecture rtl of data_memory is
    type memory_array is array (0 to N - 1) of std_logic_vector(7 downto 0);
    signal memory : memory_array := (others => "00000000");
begin
    synchronous_operation : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                memory <= (others => "00000000");
            else
                --PC is written to on every cycle
                memory(10)(4 downto 0) <= pc_in(12 downto 8);
                memory(2) <= pc_in(7 downto 0);

                if not ((address = "0000011") and (we = '1')) then
                    --Making sure that writing over the status registers actually overrides them 
                    memory(3)(2 downto 0) <= status_in;
                end if;

                if (we = '1') and (address = "0000000") then
                    if memory(4)(6 downto 0) /= "0000000" then 
                        memory(to_integer(unsigned(memory(4)(6 downto 0)))) <= data_in;
                    end if;
                else
                    memory(to_integer(unsigned(address))) <= data_in;                    
                end if;
                if memory(4)(6 downto 0) /= "0000000" then
                    memory(0) <= memory(to_integer(unsigned(memory(4)(6 downto 0))));
                else
                    memory(0) <= "00000000";
                end if;
            end if;
        end if;
    end process;
    --Output ports from the memory
    data_out <= memory(to_integer(unsigned(address)));
    pc_out <= memory(10)(4 downto 0) & memory(2);
    status_out <= memory(3)(2 downto 0);
    PORTA <= memory(5)(4 downto 0);
    PORTB <= memory(6);


end architecture rtl;