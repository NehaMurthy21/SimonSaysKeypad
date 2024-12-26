LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY pulse_detector IS

END pulse_detector;

ARCHITECTURE Behavioral OF pulse_detector IS
    SIGNAL clk_tb : STD_LOGIC := '1';
    SIGNAL rst_tb : STD_LOGIC;
    SIGNAL input_sig : STD_LOGIC;
    SIGNAL output_00 : STD_LOGIC;
    SIGNAL output_01 : STD_LOGIC;
    SIGNAL output_10 : STD_LOGIC;
    CONSTANT Clock_Period : TIME := 8 ns;
BEGIN

    rising : ENTITY work.pulse_detector
        generic map (type_detection => "00")
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            input_pulse => input_sig,
            output_pulse => output_00);
    
    falling : ENTITY work.pulse_detector
        generic map (type_detection => "01")
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            input_pulse => input_sig,
            output_pulse => output_01);
    
    both : ENTITY work.pulse_detector
        generic map (detect_type => "10")
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            input_pulse => input_sig,
            output_pulse => output_10);
            

    PROCESS
    BEGIN

clk_tb<= '1';
wait for 20 ns;
clk_tb <= '0';
wait for 20 ns;
    END PROCESS;

    PROCESS
    BEGIN
        rst_tb <= '1';
        WAIT FOR Clock_Period;
        rst_tb <= '0';
        WAIT;
    END PROCESS;
    
    PROCESS
    BEGIN
        input_sig <= '0';
        WAIT FOR 5 * Clock_Period;
        input_sig <= '1';
        WAIT FOR 10 * Clock_Period;
        input_sig <= '0';
        WAIT FOR 15 * Clock_Period;
        input_sig <= '1';
        WAIT FOR 10 * Clock_Period;
        input_sig <= '0';
        WAIT FOR 5 * Clock_Period;
        stop;
    END PROCESS;

END Behavioral;