LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY random_pattern_generator_tb IS

END random_pattern_generator_tb;

ARCHITECTURE Behavioral OF random_pattern_generator_tb IS
    SIGNAL clk_tb : STD_LOGIC := '0';
    SIGNAL rst_tb : STD_LOGIC;
    SIGNAL patter_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL output_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);
    CONSTANT CP : TIME := 8 ns;
BEGIN

    uut : ENTITY work.random_pattern_generator
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            pattern => patter_tb,
            rand_out => output_tb
        );

    clock: process
    begin
       

        
        clk_tb<= '1';
        wait for 20 ns;
        clk_tb <= '0';
        wait for 20 ns;
            end process;

    pattern : PROCESS
    BEGIN
        patter_tb <= x"65";
        rst_tb <= '0';
        WAIT FOR CP;
        rst_tb <= '1';
        WAIT FOR CP;
        rst_tb <= '0';
        WAIT FOR 10 * CP;

        rst_tb <= '1';
        WAIT FOR 2 * CP;
        rst_tb <= '0';
        WAIT FOR 20 * CP;

        rst_tb <= '1';
        WAIT FOR 3 * CP;
        rst_tb <= '0';
        WAIT FOR 30 * CP;
        stop;
    END PROCESS;

END Behavioral;