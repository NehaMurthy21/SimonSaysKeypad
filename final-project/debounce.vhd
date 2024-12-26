LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity debounce IS
    generic (
        clk_freq : INTEGER := 125_000_000; 
        time_stable : INTEGER := 10);
    port (
        clk : IN STD_LOGIC; 
        rst : IN STD_LOGIC; 
        button : IN STD_LOGIC; 
        output : OUT STD_LOGIC);
end debounce;

architecture Behavioral OF debounce IS
    signal a : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal scaler : STD_LOGIC;
begin
    process (clk, rst)
        variable count : INTEGER := 0;
    begin
        if rst = '1' then
            output <= '0';
            a <= "00";
        elsif rising_edge(clk) then
            a(0) <= button;
            a(1) <= a(0);
            if scaler = '1' then
                count := 0;
            elsif count < clk_freq * time_stable/1000 then
                count := count + 1;
            else
                output <= a(1);
end if;       
end if;    
    end process;
    scaler <= a(0) XOR a(1);
END Behavioral;