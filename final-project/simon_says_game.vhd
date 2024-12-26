library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith;


entity simon_says_game is
    Generic (
        clk_freq : positive := 125_000_000;
        width_adder : integer := 4;
        width_data : integer := 4
    );
    Port (
        clk: in std_logic;
        btn : in std_logic_vector(3 downto 0);
        switches : in std_logic_vector(3 downto 0);
        led : out std_logic_vector(3 downto 0);
        red_led, green_led, blue_led : out std_logic;
        segment_output_display_score : out std_logic_vector(6 downto 0);
        an : out std_logic
    );
end simon_says_game;

architecture Behavioral of simon_says_game is
    type mem_2d_type is array (0 to 2**width_adder - 1) of std_logic_vector(width_data-1 downto 0);
    signal array_reg : mem_2d_type;
    signal green_led_sig : std_logic;
    signal blue_led_sig : std_logic;



    signal rst : std_logic;
    signal led_sig : std_logic_vector(3 downto 0);


    type game_state IS (CAPTURE_VALUE, HOLD_VALUE, LOAD_VALUE, PATTERN, CHECK_VALUE, CORRECT_VALUE, HIGHSCORE_VALUE, WRONG_VALUE, SCORE, GAMEOVER);
    SIGNAL state : game_state;
    constant load_pattern : natural := 15;
    constant max_number_pattern : natural := 9;

    signal pattern_sig : std_logic_vector(7 DOWNTO 0) := x"64";
    signal rand_out_top : std_logic_vector(3 downto 0);
    signal rand_num : std_logic_vector(3 downto 0);

    constant period : integer := (CLK_FREQ/8);
    signal speed : integer;
    signal flash : integer;

    signal clk_div : std_logic;
     signal clk_difference : std_logic;
     signal clk_fl : std_logic;
    signal counter_div : natural;
    signal counter_diff : natural;
    signal counter_flash : natural;
   signal counter_hold : natural;
    signal pattern_flashing : boolean;


    signal switch_speed : std_logic_vector(4 downto 0);
    signal counter_speed : integer;
    signal clk_speed : std_logic;
    constant speed_0 : integer := (CLK_FREQ/2);
    constant speed_1 : integer := (CLK_FREQ/4);
    constant speed_2 : integer := (CLK_FREQ/16);
    constant speed_4 : integer := (CLK_FREQ/32);
    constant speed_8 : integer := (CLK_FREQ/64);
    constant SPEED_SIM : integer := (CLK_FREQ/1024);


    signal counter_correct : natural;
    signal counter_score : natural;
    signal score_high : natural;
    signal counter_wrong : natural;
    signal load_counter : natural;
    signal pattern_counter : natural;
    signal curr_game_counter : natural;
    signal btn_counter : natural;

    signal btn_debounce : std_logic_vector(3 downto 0);
    signal btn_pulse : std_logic_vector(3 downto 0);
    signal btn_led : std_logic_vector(width_data-1 downto 0);
    signal data : std_logic_vector(width_data-1 downto 0);


begin

    rand_gen: entity work.random_pattern_generator
        port map (
            clk => clk,
            rst => rst,
            pattern => pattern_sig,
            rand_out => rand_out_top
        );

    btn0: entity work.debounce
        generic map (
            CLK_FREQ => CLK_FREQ,
            time_stable => 10
        )
        port map (
            clk => clk,
            rst => '0',
            button => btn(0),
            output => btn_debounce(0)
        );

    btn1: entity work.debounce
        generic map (
            CLK_FREQ => CLK_FREQ,
            time_stable => 10
        )
        port map (
            clk => clk,
            rst => '0',
            button => btn(1),
            output => btn_debounce(1)
        );

    btn2: entity work.debounce
        generic map (
            CLK_FREQ => CLK_FREQ,
            time_stable => 10
        )
        port map (
            clk => clk,
            rst => '0',
            button => btn(2),
            output => btn_debounce(2)
        );

    btn3: entity work.debounce
        generic map (
            CLK_FREQ => CLK_FREQ,
            time_stable => 10
        )
        port map (
            clk => clk,
            rst => '0',
            button => btn(3),
            output => btn_debounce(3)
        );

    p0: entity work.pulse_detector
        generic map (
            type_detection => "00"
        )
        port map (
            clk => clk,
            rst => rst,
            input_pulse => btn_debounce(0),
            output_pulse => btn_pulse(0)
        );

    p1: entity work.pulse_detector
        generic map (
            type_detection => "00" 
        )
        port map (
            clk => clk,
            rst => rst,
            input_pulse => btn_debounce(1),
            output_pulse => btn_pulse(1)
        );

    p2: entity work.pulse_detector
        generic map (
            type_detection => "00"
        )
        port map (
            clk => clk,
            rst => rst,
            input_pulse=> btn_debounce(2),
            output_pulse => btn_pulse(2)
        );

    p3: entity work.pulse_detector
        generic map (
            type_detection => "00" 
        )
        port map (
            clk => clk,
            rst => rst,
            input_pulse => btn_debounce(3),
            output_pulse => btn_pulse(3)
        );




    rst <= btn(0) and btn(3);


    led <= led_sig;

    btn_led <=  x"1" when btn_pulse(0) = '1' else
 x"2" when btn_pulse(1) = '1' else
 x"4" when btn_pulse(2) = '1' else
 x"8" when btn_pulse(3) = '1' else
 x"0";



    rand_num_shift: process (rand_out_top)
    begin
        rand_num <= rand_out_top(0) & rand_out_top(3 downto 1);
    end process;

    -- FSM
    FSM: process(clk, rst)
    begin
        if rst = '1' then
            state <= CAPTURE_VALUE;
            curr_game_counter <= 1;
            score_high <= 0;
        elsif rising_edge(clk) then
            case state is
                when CAPTURE_VALUE =>
                    if btn_pulse(1) = '1' then
                        state <= LOAD_VALUE;
                    else
                        state <= CAPTURE_VALUE;
                    end if;

                when CHECK_VALUE =>
                    if (btn_pulse(0) = '1' or btn_pulse(1) = '1' or btn_pulse(2) = '1' or btn_pulse(3) = '1') then
                        if (btn_led = array_reg(btn_counter))  then
                            state <= CHECK_VALUE;
                        elsif (btn_led /= array_reg(btn_counter)) then
                            state <= WRONG_VALUE;
                        end if;
                    elsif (btn_counter = curr_game_counter) then
                        state <= CORRECT_VALUE;
                    end if;

                when PATTERN =>
                    if pattern_counter = curr_game_counter then
                        state <= CHECK_VALUE;
                    else
                        state <= PATTERN;
                    end if;
                    
                when LOAD_VALUE =>
                    if load_counter = load_pattern then
                        state <= HOLD_VALUE;
                    else
                        state <= LOAD_VALUE;
                    end if;

                when HOLD_VALUE =>
                    if counter_hold = 4 then
                        state <= PATTERN;
                    else
                        state <= HOLD_VALUE;
                    end if;
                 when HIGHSCORE_VALUE =>
                    state <= SCORE;

                when CORRECT_VALUE =>
                    if counter_correct = 4 then
                        curr_game_counter <= curr_game_counter + 1;
                        score_high <= score_high + 1;
                        if score_high = max_number_pattern then
                            state <= HIGHSCORE_VALUE;
                        else
                            state <= PATTERN;
                        end if;
                    end if;

            
                when WRONG_VALUE =>
                    if counter_wrong = 4 then
                        state <= SCORE;
                    else
                        state <= WRONG_VALUE;
                    end if;

                when SCORE =>
                    if counter_score = 2*score_high then
                        state <= GAMEOVER;
                    end if;

                when GAMEOVER =>


                when others =>
                    state <= CAPTURE_VALUE;
            end case;
        end if;
    end process;


    holding_p: process(clk_div, rst)
    begin
        if rst = '1' then
            counter_hold <= 0;
        elsif rising_edge(clk_div) then
            if state = HOLD_VALUE then
                counter_hold <= counter_hold + 1;
            else
                counter_hold <= 0;
            end if;
        end if;
    end process;

    loading_p: process(clk, rst)
    begin
        if rst = '1' then
            load_counter <= 0;
        elsif rising_edge(clk) then
            if state = LOAD_VALUE then
                array_reg(load_counter) <= rand_num;
                load_counter <= load_counter + 1;
            else
                load_counter <= 0;
            end if;
        end if;
    end process;

    flash_p: process(clk_speed, rst)
    begin
        if rst = '1' then
            led_sig <= x"0";
            pattern_flashing <= true;
            pattern_counter <= 0;
        elsif rising_edge(clk_speed) then
            if state = PATTERN then
                if pattern_flashing then
                    pattern_counter <= pattern_counter + 1;
                    led_sig <=  array_reg(pattern_counter);
                    pattern_flashing <= false;
                else
                    pattern_flashing <= true;
                    led_sig <= x"0";
                end if;
            else
                pattern_counter <= 0;
                led_sig <= x"0";
            end if;
            if state = GAMEOVER or state = CAPTURE_VALUE then
                led_sig <= rand_out_top;
            end if;
        end if;
    end process;

    checking_p: process(clk, rst)
    begin
        if rst = '1' then
            btn_counter <= 0;
        elsif rising_edge(clk) then
            if state = CHECK_VALUE then
                if (btn_led = array_reg(btn_counter)) and (btn_pulse(0) = '1' or btn_pulse(1) = '1' or btn_pulse(2) = '1' or btn_pulse(3) = '1') then
                    btn_counter <= btn_counter + 1;
                end if;
            else
                btn_counter <= 0;
            end if;
        end if;
    end process;



    corresct_flash_p: process(clk_div, rst)
    begin
        if rst = '1' then
            counter_correct <= 0;
            green_led <= '0';
        elsif rising_edge(clk_div) then
            if state = CORRECT_VALUE then
                counter_correct <= counter_correct + 1;
                green_led <= not green_led_sig;
            else
                counter_correct <= 0;
                green_led <= '0';


            end if;
        end if;
    end process;


    wrong_p: process(clk_div, rst)
    begin
        if rst = '1' then
            counter_wrong <= 0;
            red_led <= '0';
        elsif rising_edge(clk_div) then
            if state = WRONG_VALUE then
                counter_wrong <= counter_wrong + 1;
                red_led <= '1';
            else
                red_led <= '0';
                counter_wrong <= 0;
            end if;
        end if;
    end process;


    score_p: process(clk_div, rst)
    begin
        if rst = '1' then
            counter_score <= 0;
            blue_led <= '0';

        elsif rising_edge(clk_div) then
            if state = SCORE then
                if counter_score /= 2*score_high then


                    counter_score <= counter_score + 1;

                    blue_led <= not blue_led_sig;

--SSD displays the final score based on the blue light
                    case counter_score is
                        when 0 => segment_output_display_score <= "1111110"; --0
                        when 1 => segment_output_display_score <= "0110000"; --1
                        when 2 => segment_output_display_score <= "1101101"; --2
                        when 3 => segment_output_display_score <= "1111001"; --3
                        when 4 => segment_output_display_score <= "0110011"; --4
                        when 5 => segment_output_display_score <= "1011011"; --5
                        when 6 => segment_output_display_score <= "1011111"; --6
                        when 7 => segment_output_display_score <= "1110000"; --7
                        when 8 => segment_output_display_score <= "1111111"; --8
                        when 9=> segment_output_display_score <= "1111011"; --9
--                        when A => segment_output_display_score <= "1110111"; --A
--                        when "1011" => segment_output_display_score <= "0011111"; -- B
--                        when "1100" => segment_output_display_score <= "1001110"; --C
--                        when "1101" => segment_output_display_score <= "0111101"; -- D
--                        when "1110" => segment_output_display_score <= "1001111"; --E
--                        when "1111" => segment_output_display_score <= "1000111"; --F
                        when others => segment_output_display_score<="0000010";


                    end case;
                end if;

            else
                counter_score <= 0;
                blue_led <= '0';
            end if;
        end if;


    end process;

    clk_div_p : process (clk, rst)
    begin
        if rst = '1' then
            clk_div <= '0';
            counter_div <= 0;
        elsif rising_edge(clk) then
            counter_div <= counter_div + 1;
            if counter_div = period-1 then
                clk_div <= not clk_div;
                counter_div <= 0;
            end if;
        end if;
    end process;
--we can adjust speed through the switches (0000-slowest and 1111- fastest)
    game_speed_p : process(clk, rst)
    begin
        if rst = '1' then
            clk_speed <= '0';
            counter_speed <= 0;
            switch_speed <= "00000";
        elsif rising_edge(clk) then
            counter_speed <= counter_speed + 1;
            case switches is
                when x"0" =>
                    if switch_speed(0) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "00001";
                    end if;
                    if counter_speed = speed_0-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;
                when x"1" =>
                    if switch_speed(1) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "00010";
                    end if;
                    if counter_speed = speed_1-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;
                when x"2" =>
                    if switch_speed(2) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "00100";
                    end if;
                    if counter_speed = speed_2-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;
                when x"4" =>
                    if switch_speed(3) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "01000";
                    end if;
                    if counter_speed = speed_4-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;

                when x"8" =>
                    if switch_speed(4) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "10000";
                    end if;
                    if counter_speed = speed_8-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;

                when x"f" =>
                    if switch_speed(4 downto 3) = "00" then
                        counter_speed <= 0;
                        switch_speed <= "11000";
                    end if;
                    if counter_speed = SPEED_SIM-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;

                when others =>
                    if switch_speed(0) = '0' then
                        counter_speed <= 0;
                        switch_speed <= "00001";
                    end if;
                    if counter_speed = speed_0-1 then
                        clk_speed <= not clk_speed;
                        counter_speed <= 0;
                    end if;
            end case;
        end if;
    end process;
    blue_led <= blue_led_sig;
    green_led <= green_led_sig;
end Behavioral;