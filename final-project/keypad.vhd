----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2024 04:09:00 PM
-- Design Name: 
-- Module Name: keypad - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity keypad is
port (
        clk: in std_logic;
        btn : in std_logic_vector(2 downto 0);
        row : in std_logic_vector(3 downto 0);
        column : out std_logic_vector(3 downto 0);
        seg_out : out std_logic_vector(6 downto 0);
        an : out std_logic

);
end keypad;

architecture Behavioral of keypad is

signal number : std_logic_vector(3 downto 0);
signal debounce : std_logic;
signal anode :   std_logic;

component decoder 
port(
        clk, rst : in std_logic;
        row : in  std_logic_vector (3 downto 0);
        col : out  std_logic_vector (3 downto 0);
        output : out  std_logic_vector (3 downto 0)
     );
end component;



component ssd_controller
port (
        number_inputted : in std_logic_vector(3 downto 0);
        segment : out std_logic_vector(6 downto 0)
     );
end component;
begin


decode: decoder
 port map
 (clk => clk,
  rst => debounce, 
  row => row,
   col => column, 
   output => number);

ssd : ssd_controller 
port map
(number_inputted => number,
 segment => seg_out);

an<=anode;
end Behavioral; 