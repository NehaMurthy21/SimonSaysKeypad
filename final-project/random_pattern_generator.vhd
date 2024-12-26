LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY random_pattern_generator IS
    PORT (
        clk, rst : IN STD_LOGIC;
        pattern : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rand_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END random_pattern_generator;

ARCHITECTURE Behavioral OF random_pattern_generator IS

    SIGNAL current_state : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL next_state : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL output : STD_LOGIC;
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state <= pattern;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    output <= current_state(4) XOR current_state(3) XOR current_state(2) XOR current_state(0);
    next_state <= output & current_state(7 DOWNTO 1);
    rand_out <= "0001" when current_state(7 DOWNTO 6) = "00" else
                "0010" when current_state(7 DOWNTO 6) = "01" else
                "0100" when current_state(7 DOWNTO 6) = "10" else
                "1000" when current_state(7 DOWNTO 6) = "11";

END Behavioral;