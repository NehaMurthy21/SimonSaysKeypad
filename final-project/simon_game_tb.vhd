library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

entity simon_game_tb is
end simon_game_tb;

architecture Behavioral of simon_game_tb is
    type p_array is array (0 to 1) of integer range 0 to 8;
    signal pattern : p_array := (1, 2); 
    signal clk_tb : std_logic := '1';
    signal btn_tb : std_logic_vector(3 downto 0);
    signal switches_tb : std_logic_vector(3 downto 0);
    signal led_tb : std_logic_vector(3 downto 0);
    signal rgb_r_tb, rgb_g_tb, rgb_b_tb : std_logic;

    constant CP : time := 8 ns;
    constant CLK_FREQ_tb : positive := 125_000_000;

    constant wait_time : time := 11 ms;
    constant two_ms : time := 4 ms;

    signal green_led_sig, red_led_on, blue_led_sig : boolean := false;

begin
    uut: entity work.simon_says_game
        generic map (
            CLK_FREQ => CLK_FREQ_tb
        )
        port map (
            clk => clk_tb,
            btn => btn_tb,
            switches => switches_tb,
            led => led_tb,
            red_led => rgb_r_tb,
            green_led => rgb_g_tb,
            blue_led => rgb_b_tb
        );

    clock: process
    begin
      

        
        clk_tb<= '1';
        wait for 20 ns;
        clk_tb <= '0';
        wait for 20 ns;
            end process;

    stimulus: process
    begin
        btn_tb <= (others => '0');
        wait for 10 ms;
        btn_tb(0) <= '1';
        btn_tb(3) <= '1';
        wait for wait_time;
        btn_tb(0) <= '0';
        btn_tb(3) <= '0';
        wait for 10 ms;

-- speed
        switches_tb <= "1111";

        for i in 0 to pattern'high loop
            btn_tb(0) <= '1';
            wait for wait_time;
            btn_tb(0) <= '0';
            wait for 10 ms;
            
             btn_tb(3) <= '1';
            wait for wait_time;
            btn_tb(3) <= '0';
            wait for 10 ms;
            
            if pattern(i) = 1 then
                green_led_sig <= true;
                wait until rising_edge(clk_tb);
                green_led_sig <= false;
            else
                red_led_on <= true;
                wait until rising_edge(clk_tb);
                red_led_on <= false;
            end if;
        end loop;

        for i in 1 to pattern'length loop
            for j in 1 to i loop
                blue_led_sig <= true;
                wait until rising_edge(clk_tb);
                blue_led_sig <= false;
                wait for 100 ms; 
            end loop;
            wait for 100 ms; 
        end loop;

        wait;
    end process;

    led_control_process: process(clk_tb)
    begin
        if rising_edge(clk_tb) then
            if green_led_sig then
                rgb_g_tb <= '1';
            else
                rgb_g_tb <= '0';
            end if;
            
            if red_led_on then
                rgb_r_tb <= '1';
            else
                rgb_r_tb <= '0';
            end if;
            
            if blue_led_sig then
                rgb_b_tb <= '1';
            else
                rgb_b_tb <= '0';
            end if;
        end if;
    end process;

end Behavioral;