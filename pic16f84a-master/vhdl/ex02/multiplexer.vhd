---------------------------
--Multiplexer
---------------------------
--A and B   : Data inputs for mux to select from, 8 bit;
--S         : Selection pin
--Q         : Output data, 8 bit
---------------------------


entity multiplexer is
    port   (S       : in bit;
            A, B    : in bit_vector(7 DOWNTO 0);
            Q       : out bit_vector(7 DOWNTO 0));
end entity multiplexer;

architecture rtl of multiplexer is
begin
    muxing : process(S, A, B)
    begin
        if S then
            Q <= B;
        else
            Q <= A;
        end if;
    end process;

end architecture rtl;
