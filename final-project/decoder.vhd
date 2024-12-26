library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    port (
        clk, rst : in std_logic;
        row : in std_logic_vector(3 downto 0);
        col : out std_logic_vector(3 downto 0);
        output : out std_logic_vector(3 downto 0)
    );
end decoder;

architecture Behavioral of decoder is

    signal place_on_kypd : std_logic_vector(19 downto 0):= (others => '0');

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if (rst = '1') then

                output <= "0000";

            end if;
-- create an if statement for each column and the numbers in the row like a matrix (Keypad)
            if place_on_kypd = "00011000011010100000" then 
                col <= "0111";
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "00011000011010101000" then    
                --Row 1 numbers
                if row = "0111" then
                    output <= "0001"; --1
                    --Row 2 numbers
                elsif row = "1011" then
                    output <= "0100"; --4
                    --Row 3 numbers
                elsif row = "1101" then
                    output <= "0111"; --7
                    --Row 4 numbers
                elsif row = "1110" then
                    output <= "0000"; --0
                end if;
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "00110000110101000000" then    
                --Column 2
                col <= "1011";
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "00110000110101001000" then   
                --Row 1 numbers
                if row = "0111" then
                    output <= "0010"; --2
                    --Row 2 numbers
                elsif row = "1011" then
                    output <= "0101"; --5
                    --Row 3 numbers
                elsif row = "1101" then
                    output <= "1000"; --8
                    --Row 4 numbers
                elsif row = "1110" then
                    output <= "1111"; --F
                end if;
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "01001001001111100000" then 
                --Column 3
                col <= "1101";
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "01001001001111101000" then 
                --Row 1 numbers
                if row = "0111" then
                    output <= "0011"; --3
                    --Row 2 numbers
                elsif row = "1011" then
                    output <= "0110"; --6
                    --Row 3 numbers
                elsif row = "1101" then
                    output <= "1001"; --9
                    --Row 4 numbers
                elsif row = "1110" then
                    output <= "1110"; --E
                end if;
                place_on_kypd <= place_on_kypd + 1;

            elsif place_on_kypd = "01100001101010000000" then 
                --Column 4
                col <= "1110";
                place_on_kypd <= place_on_kypd + 1;
            elsif place_on_kypd = "01100001101010001000" then 
                --Row 1 numbers
                if row = "0111" then
                    output <= "1010"; --A
                    --Row 2 numbers 
                elsif row = "1011" then
                    output <= "1011"; --B
                    --Row 3 numbers 
                elsif row = "1101" then
                    output <= "1100"; --C
                    --Row 4 numbers 
                elsif row = "1110" then
                    output <= "1101"; --D
                end if;
                place_on_kypd <= "00000000000000000000";
            else
                place_on_kypd <= place_on_kypd + 1;
            end if;
        end if;
    end process;
end Behavioral;