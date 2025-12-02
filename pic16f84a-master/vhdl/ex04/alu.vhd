--------------------------------
--ALU for PIC16 microcontroller
--------------------------------
--A and B       : Data inputs, 8 bits
--result        : result of the operation, 8 bits
--bit_select    : bit selection for bit operations, 3 bits
--status_in     : status from the previous cycle
--status        : status in the current cycle
--Operation     : Given instruction for the ALU, custom enum. "Op".
----Available operations: (names in parenthesis are the names used if not original)
--Arithmetic:
----ADD
----COMP (COM)
----DEC
----INC
----SUB
--Bit operations
----BSF and BCF
--Logic operations
----AND (ANP)
----IOR
----XOR (XOP)
--Misc. operations
----SWAP (SWP)
----RLF and RRF
----MOV
----CLR

library ieee; 

use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.operation_package.all;

entity alu is
    port (A, B          : in std_logic_vector (7 downto 0);
          operation     : in op_type;
          bit_select    : in std_logic_vector (2 downto 0);
          status_in     : in std_logic_vector (2 downto 0);
          result        : out std_logic_vector (7 downto 0);
          status        : out std_logic_vector (2 downto 0));
end entity alu;

architecture rtl of alu is

    component ripple_adder_pic is
    port    (A, B       : in std_logic_vector(7 downto 0);
             CI         : in std_logic;
             S          : out std_logic_vector(7 downto 0);
             C, DC      : out std_logic);
    end component;
    signal A_add, B_add     : std_logic_vector(7 downto 0);
    signal CI_add           : std_logic;
    signal S_add            : std_logic_vector(7 downto 0);
    signal C_add, DC_add    : std_logic;

    component XORer
        port (A     : in std_logic_vector (7 downto 0);
              B     : in std_logic_vector (7 downto 0);
              Q     : out std_logic_vector (7 downto 0));
    end component XORer;
    signal A_xor, B_xor, Q_xor   : std_logic_vector(7 downto 0);

    component ORer
        port (A     : in std_logic_vector (7 downto 0);
              B     : in std_logic_vector (7 downto 0);
              Q     : out std_logic_vector (7 downto 0));
    end component ORer;
    signal A_or, B_or, Q_or   : std_logic_vector(7 downto 0);


    component ANDer
        port (A     : in std_logic_vector (7 downto 0);
              B     : in std_logic_vector (7 downto 0);
              Q     : out std_logic_vector (7 downto 0));
    end component ANDer;
    signal A_and, B_and, Q_and   : std_logic_vector(7 downto 0);
    
    component swapper is 
        port (A     : in std_logic_vector (7 downto 0);
              Q     : out std_logic_vector (7 downto 0));
    end component swapper;
    signal A_swp, Q_swp          : std_logic_vector(7 downto 0);

    component bit_setter is
        port (A             : in std_logic_vector (7 downto 0);
              bit_select    : in std_logic_vector (2 downto 0);
              B             : in std_logic;
              Q             : out std_logic_vector (7 downto 0));
    end component bit_setter;

    signal A_set, Q_set          : std_logic_vector(7 downto 0);
    signal bit_select_set        : std_logic_vector(2 downto 0);
    signal B_set                 : std_logic;
    

    component shifter is
    port(A          : in std_logic_vector (7 downto 0);
         CI, dir    : in std_logic;
         Q          : out std_logic_vector (7 downto 0);
         CO         : out std_logic);
    end component shifter;
    signal A_shift, Q_shift                 : std_logic_vector(7 downto 0);
    signal CI_shift, CO_shift, dir_shift    : std_logic;

    signal first_result            : std_logic_vector(7 downto 0);
begin


    working : process (all)

    procedure adding (A_from    : in std_logic_vector(7 downto 0);
                      B_from    : in std_logic_vector(7 downto 0);
                      CI_from   : in std_logic) is
    begin
        A_add <= A_from;
        B_add <= B_from;
        CI_add <= CI_from;
        result <= S_add;
        status(0) <= C_add;
        status(1) <= DC_add;
        status(2) <= nor(result);
    end procedure;

    procedure XORing   (A_from          : in std_logic_vector(7 downto 0);
                        B_from          : in std_logic_vector(7 downto 0);
                        signal Q_from   : out std_logic_vector(7 downto 0)) is
    begin
        A_xor <= A_from;
        B_xor <= B_from;
        Q_from <= Q_xor;
        status(2) <= nor(Q_xor);

    end procedure;

    procedure ORing    (A_from          : in std_logic_vector(7 downto 0);
                        B_from          : in std_logic_vector(7 downto 0);
                        signal Q_from   : out std_logic_vector(7 downto 0)) is
    begin
        A_or <= A_from;
        B_or <= B_from;
        Q_from <= Q_or;
        status(2) <= nor(Q_or);

    end procedure;
 
    procedure ANDing    (A_from          : in std_logic_vector(7 downto 0);
                        B_from          : in std_logic_vector(7 downto 0);
                        signal Q_from   : out std_logic_vector(7 downto 0)) is
    begin
        A_and <= A_from;
        B_and <= B_from;
        Q_from <= Q_and;
        status(2) <= nor(Q_and);

    end procedure;       
    procedure swapping (A_from          : in std_logic_vector(7 downto 0);
                        signal Q_from   : out std_logic_vector(7 downto 0)) is
    begin
        A_swp <= A_from;
        Q_from <= Q_swp;
    end procedure;

    procedure shifting (A_from              : in std_logic_vector (7 downto 0);
                        dir_from            : in std_logic;
                        signal Q_from       : out std_logic_vector (7 downto 0)) is
    begin
        A_shift <= A_from;
        CI_shift <= status_in(0);
        dir_shift <= dir_from;
        Q_from <= Q_shift;
        status(0) <= CO_shift;
    end procedure;

    procedure setting (A_from           : in std_logic_vector (7 downto 0);
                       bit_select_from  : in std_logic_vector (2 downto 0);
                       B_from           : in std_logic;
                       signal Q_from    : out std_logic_vector (7 downto 0)) is
    begin
        A_set <= A_from;
        bit_select_set <= bit_select_from;
        B_set <= B_from;
        Q_from <= Q_set;
    end procedure;

    begin
--Default values set so no latches are inferred, but a mux (as it should be)
        status <= status_in;
        A_add <= "00000000";
        B_add <= "00000000";
        CI_add <= '0';
        A_xor <= "00000000";
        B_xor <= "00000000";
        A_or <= "00000000";
        B_or <= "00000000";
        A_and <= "00000000";
        B_and <= "00000000";
        A_swp <= "00000000";
        A_shift <= "00000000";
        CI_shift <= '0';
        dir_shift <= '0';
        A_set <= "00000000";
        bit_select_set <= "000";
        B_set <= '0';
        first_result <= "00000000";

        case operation is
            when ADD =>
                adding ( A, B, '0');
            when SUB =>
                XORing ( B, "11111111", first_result);
                adding ( A, first_result , '1');
            when INC =>
                adding ( A, "00000001", '0');
                status(0) <= '0';
                status(1) <= '0';
            when DEC =>
                adding ( A, "11111110" , '1');
                status(0) <= '0';
                status(1) <= '0';
            when COM =>
                XORing ( A, "11111111", result);
            when XOP =>
                XORing ( A, B, result);
            when IOR =>
                ORing ( A, B, result);
            when ANP =>
                ANDing ( A, B, result);
            when RRF =>
                shifting ( A, '1', result);
            when RLF =>
                shifting ( A, '0', result);
            when BCF =>
                setting (A, bit_select, '0', result);
            when BSF =>
                setting (A, bit_select, '1', result);
            when SWP =>
                swapping (A, result);
            when MOV =>
                result <= A;
            when CLR =>
                result <= "00000000";
            when others =>
                null;
            end case;

    end process;
    


    adder_used : ripple_adder_pic
        port map   (A => A_add,
                    B => B_add,
                    CI => CI_add,   
                    S => S_add,
                    C => C_add,
                    DC => DC_add);

    XORer_used : XORer
        port map   (A => A_xor,
                    B => B_xor,
                    Q => Q_xor);

    ORer_used : ORer
        port map   (A => A_or,
                    B => B_or,
                    Q => Q_or);
    ANDer_used : ANDer
        port map   (A => A_and,
                    B => B_and,
                    Q => Q_and);
        
    swapper_used : swapper
        port map   (A => A_swp,
                    Q => Q_swp);

    bit_setter_used : bit_setter
        port map   (A => A_set,
                    bit_select => bit_select_set,
                    B => B_set,
                    Q => Q_set);

    shifter_used : shifter
        port map   (A => A_shift,
                    CI => CI_shift,
                    dir => dir_shift,
                    Q => Q_shift,
                    CO => CO_shift);

end architecture rtl;
