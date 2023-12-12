--// ============================================================================
--// Copyright (c) 2012 by Terasic Technologies Inc.
--// ============================================================================
--//
--// Permission:
--//
--//   Terasic grants permission to use and modify this code for use
--//   in synthesis for all Terasic Development Boards and Altrea Development 
--//   Kits made by Terasic.  Other use of this code, including the selling 
--//   ,duplication, or modification of any portion is strictly prohibited.
--//
--// Disclaimer:
--//
--//   This VHDL or Verilog source code is intended as a design reference
--//   which illustrates how these types of functions can be implemented.
--//   It is the user's responsibility to verify their design for
--//   consistency and functionality through the use of formal
--//   verification methods.  Terasic provides no warranty regarding the use 
--//   or functionality of this code.
--//
--// ============================================================================
--//           
--//  Terasic Technologies Inc
--//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
--//
--//
--//
--//                     web: http://www.terasic.com/
--//                     email: support@terasic.com
--//
--// ============================================================================
--//
--// Major Functions:i2c controller
--//
--// ============================================================================
--//
--// Revision History :
--// ============================================================================
--//   Ver  :| Author            :| Mod. Date :| Changes Made:
--//   V1.0 :| Joe Yang          :| 05/07/10  :|      Initial Revision
--// ============================================================================

-- Translated to VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Controller is 
	port (
		CLOCK    : in    std_logic;
		I2C_DATA : in    std_logic_vector(23 downto 0);
		GO_t     : in    std_logic;
		RESET_n  : in    std_logic;
		I2C_SDAT : inout std_logic;
		I2C_SCLK : out   std_logic;
		END_t    : out   std_logic;
		ACK      : out   std_logic
		
	);
end I2C_Controller;

architecture Behavior of I2C_Controller is
	signal SDO        : std_logic;
	signal SCLK       : std_logic;
	signal SD         : std_logic_vector(23 downto 0);
	signal SD_COUNTER : std_logic_vector(5 downto 0);
	
	signal ACK1, ACK2, ACK3 : std_logic;
begin	
	I2C_SCLK <= SCLK OR (not CLOCK) when ((SD_COUNTER >= "000100") AND (SD_COUNTER <="011110")) else
					SCLK;
	I2C_SDAT <= 'Z' when SDO = '1' else '0';
	
	ACK <= ACK1 or ACK2 or ACK3;
	
	-- I2C COUNTER
	process (RESET_n, CLOCK)
	begin
		if(rising_edge(CLOCK)) then
			if (RESET_n = '0') then
				SD_COUNTER <= (others => '1');
			else
				if (GO_t = '0') then
					SD_COUNTER <= (others => '0');
				elsif (SD_COUNTER < "111111") then
					SD_COUNTER <= std_logic_vector( unsigned(SD_COUNTER) + 1 );
				end if;
			end if;
		end if;
	end process;
	
	--
	process (RESET_n, CLOCK)
	begin
		if(rising_edge(CLOCK)) then
			if (RESET_n = '0') then
				SCLK  <= '1';
				SDO   <= '1';
				ACK1  <= '0';
				ACK2  <= '0';
				ACK3  <= '0';
				END_t <= '1';
			else
				case SD_COUNTER is
					when "000000" =>  SCLK  <= '1';
											SDO   <= '1';
											ACK1  <= '0';
											ACK2  <= '0';
											ACK3  <= '0';
											END_t <= '0';
					-- start
					when "000001" =>  SD    <= I2C_DATA;
											SDO   <= '0';
											
					when "000010" =>  SCLK  <= '0';
					-- SLAVE ADDR
					when "000011" =>  SDO   <= SD(23);
					when "000100" =>  SDO   <= SD(22);
					when "000101" =>  SDO   <= SD(21);
					when "000110" =>  SDO   <= SD(20);
					when "000111" =>  SDO   <= SD(19);
					when "001000" =>  SDO   <= SD(18);
					when "001001" =>  SDO   <= SD(17);
					when "001010" =>  SDO   <= SD(16);
					when "001011" =>  SDO   <= '1'; -- ACK
					
					-- SUB ADDR
					when "001100" =>  SDO   <= SD(15);
											ACK1  <= I2C_SDAT;
											
					when "001101" =>  SDO   <= SD(14);
					when "001110" =>  SDO   <= SD(13);
					when "001111" =>  SDO   <= SD(12);
					when "010000" =>  SDO   <= SD(11);
					when "010001" =>  SDO   <= SD(10);
					when "010010" =>  SDO   <= SD(9);
					when "010011" =>  SDO   <= SD(8);
					when "010100" =>  SDO   <= '1'; -- ACK
					
					-- DATA
					when "010101" =>  SDO   <= SD(7);
											ACK2  <= I2C_SDAT;
											
					when "010110" =>  SDO   <= SD(6);
					when "010111" =>  SDO   <= SD(5);
					when "011000" =>  SDO   <= SD(4);
					when "011001" =>  SDO   <= SD(3);
					when "011010" =>  SDO   <= SD(2);
					when "011011" =>  SDO   <= SD(1);
					when "011100" =>  SDO   <= SD(0);
					when "011101" =>  SDO   <= '1'; -- ACK
					
					
					-- STOP
					when "011110" =>  SDO    <= '0';
											SCLK   <= '0';
											ACK3   <= I2C_SDAT;
											
					when "011111" =>  SCLK   <= '1';
					
					when "100000" =>  SDO    <= '1';
											END_t  <= '1';
											
					when others   => null;
				end case;
			end if;
		end if;
	end process;
end Behavior;