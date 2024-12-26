library ieee;
use ieee.std_logic_1164.ALL;
use std.env.stop;
entity debounce_tb is

end debounce_tb;

architecture Behavioral OF debounce_tb is
    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC;
    signal button_tb : STD_LOGIC;
    signal result_tb : STD_LOGIC;
  --  constant Clock_period : TIME := 8 ns;
  --  constant debounce : TIME := 1 ns;
begin
    uut : entity work.debounce
     generic map(
            clk_freq => 125_000_000,
            time_stable => 10)
        port map(
            clk => clk_tb,
            rst => rst_tb,
            button => button_tb,
            output => result_tb
        );
clock: process
    begin
        -- clk_tb <= not clk_tb;
        -- wait for CP/2;

        
        clk_tb<= '1';
        wait for 20 ns;
        clk_tb <= '0';
        wait for 20 ns;
            end process;

    test : PROCESS
    BEGIN
         button_tb <= '0';
         rst_tb <= '1';
         WAIT FOR  20 ns;
         rst_tb <= '0';
         WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR 20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR  20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR 20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR 20 ns;

        button_tb <= '1';
        WAIT FOR 20 ms;
        button_tb <= '0';
        WAIT FOR 20 ms;

        button_tb <= '0';
        WAIT FOR 20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR  20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR 20 ns;
        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR  20 ns;

        button_tb <= '1';
        WAIT FOR  20 ns;
        button_tb <= '0';
        WAIT FOR  20 ns;

       
    END PROCESS;

END Behavioral;