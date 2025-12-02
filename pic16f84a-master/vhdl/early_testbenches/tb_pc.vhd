-----------------------------------------
--PC test bench early
-----------------------------------------

library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pc is
end entity tb_pc;

architecture behavioural of tb_pc is 
    signal goto_addr, pc                                        : std_logic_vector(12 downto 0);
    signal clk, reset, push, pop, goto, fetch, can_exec      : std_logic;

        -- Declaration of the program counter
        component program_counter is
            port   (goto_addr       : in std_logic_vector(12 downto 0);
                    clk             : in std_logic;
                    reset           : in std_logic;
                    push            : in std_logic;
                    pop             : in std_logic;
                    fetch           : in std_logic;
                    goto            : in std_logic;
                    pc              : out std_logic_vector(12 downto 0);
                    can_exec        : out std_logic);
        end component program_counter;
begin



    simulation : process
    begin
        clk <= '0';
        reset <= '0';
        goto_addr <= "0000000000000";
        push <= '0';
        pop <= '0';
        fetch <= '0';
        goto <= '0';
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
        fetch <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '0';
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
        fetch <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '0';
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
        fetch <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '1';
        goto_addr <= "0000010101010";
        goto <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        goto <= '0';
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
        fetch <= '1';
        goto_addr <= "0000011111111";
        goto <= '1';
        push <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        push <= '0';
        goto <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        fetch <= '1';
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
        fetch <= '1';
        pop <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        pop <= '0';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        pop <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        wait;
    end process;
    

         pc_DUT : program_counter
            
            port map   (goto_addr => goto_addr,
                        goto => goto,
                        clk => clk,
                        reset => reset,
                        push => push,
                        pop => pop,
                        pc => pc,
                        fetch => fetch,
                        can_exec => can_exec);


end architecture behavioural;
