----------------------------------------------------------------------------------
-- Company: INESC-ID
-- Engineer: Rui Duarte
-- 
-- Create Date: 19.05.2023 23:20:29
-- Design Name: NES_GAMEPAD
-- Module Name: nes_gamepad - Behavioral
-- Project Name: nes_gamepad_basys3
-- Target Devices: basys3
-- Tool Versions: vivado 2022.1
-- Description: interface for the (clone) nes controller
-- 
--	      +---------> Clock
--	      | +-------> Latch
--	      | | +-----> Data
--	      | | |
--    _____________
--  5 \ x o o o x / 1
--     \ x o x o / 
--    9 `~~~~~~~' 6
--	       |   |
--	       |   +----> Power
--	       +--------> Ground

-- IDC/DB9 -> PMOD JB @basys3
-- 2-DATA  -> 2-JB2 (A16)
-- 3-LATCH -> 3-JB3 (B15)
-- 4-CLOCK -> 4-JB4 (B16)
-- 6-VCC   -> 6-3V3
-- 8-GND   -> 5-GND
--
--               __    __    __    __    __    __    __    __          __    __       
-- clk    ______|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |________|  |__|  |___...
--          __                                                    __
-- latch  _|  |__________________________________________________|  |______________...
--
-- data  ___| A |  B  | STR | SEL | UP  |DOWN |LEFT |RIGHT|_______| A |  B  |...
--
--    bit: 7  6  5  4  3  2  1  0
-- output: E  W  S  N  SE ST B  A

-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity nes_gamepad is
    Port ( 
           clk       : in STD_LOGIC;
           nes_data_1  : in STD_LOGIC;          -- JB2 (A16)
			  nes_data_2  : in STD_LOGIC;
           nes_latch : out STD_LOGIC := '0';  -- JB3 (B15) 
           nes_clk   : out STD_LOGIC := '0';  -- JB4 (B16)
           state_1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
			  state_2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0')
    );
end nes_gamepad;

architecture Behavioral of nes_gamepad is
constant b : integer := 18; -- use this parameter to control the sampling rate/clock division between simulation and board

constant zeroes : std_logic_vector(b-5 downto 0) := (others => '0');

signal clk_counter : std_logic_vector(b downto 0) := (others => '0');
signal shift_data_1 : std_logic_vector(16 downto 0) := (others => '0');
signal shift_data_2 : std_logic_vector(16 downto 0) := (others => '0');
signal shift_counter : integer := 0;


begin

process (clk)
begin
    if rising_edge(clk) then
       clk_counter <= clk_counter + 1;
       case (clk_counter(b downto b-4)) is
          when "00000" => nes_latch <= '1';  nes_clk <= '0';     shift_counter <= 0;  
          when "00010" | "00100" | "00110" | "01000" | "01010" | "01100" | "01110" | "10000" => nes_clk <= '1';--| "1111" => nes_clk <= '1'; 
					if (clk_counter(b-5 downto 0) = zeroes) then
						if (clk_counter(b downto b-4) /= "11110") then
							shift_counter <= shift_counter + 1;
						end if;
					end if;
          when others =>     nes_clk <= '0';     nes_latch <= '0';  shift_data_1(shift_counter) <= nes_data_1; shift_data_2(shift_counter) <= nes_data_2;
       end case;            
    end if;
end process;


state_1 <= not shift_data_1(7 downto 0);
state_2 <= not shift_data_2(7 downto 0);


end Behavioral;
