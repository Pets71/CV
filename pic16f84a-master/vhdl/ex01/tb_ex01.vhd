---------------------------
--Multiplexer and testbench
---------------------------
--A and B   : Data inputs for mux to select from, 8 bit;
--S         : Selection pin
--Q         : Output data, 8 bit
---------------------------


entity tb_ex01 is
end entity tb_ex01;

architecture behavioural of tb_ex01 is
    signal S        : bit;
    signal A, B, Q  : bit_vector(7 DOWNTO 0);
begin
    muxing : process(S, A, B)
    begin
        if S then
            Q <= B;
        else
            Q <= A;
        end if;
    end process;

    run_sim : process is
    begin
        A <= "11110000";
        B <= "00001111";
        S <= '0';

        wait for 2 ns;
        S <= '1';
        wait for 2 ns;
        B <= "11111111";
        wait for 2 ns;
        A <= "00000000";
        wait for 2 ns;
        S <= '0';
        wait for 2 ns;
        wait;

    end process;

end architecture behavioural;
