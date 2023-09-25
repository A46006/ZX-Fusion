library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.constants.all;

entity audio_codec is
	port (
		CLK			:	in	std_logic;
		nRESET		:	in	std_logic;
		
		AUD_BCLK		:	out std_logic;
		AUD_LRCLK	:	out std_logic
	);
end audio_codec;

architecture Behavior of audio_codec is
	signal bclk : std_logic := '0';
	signal bclk_div : integer := 0;
	
	signal lrclk : std_logic := '0';
	signal lrclk_div : integer := 0;
begin	
	AUD_BCLK <= bclk;
	AUD_LRCLK <= lrclk;
	
	-- Bitstream clock generator --
	process(CLK,nRESET)
	begin
		if (nReset = '0') then
			bclk_div <= 0;
			bclk <= '0';
		else
			if (rising_edge(CLK)) then
				if (bclk_div >= audio_ref_clk/(audio_sample_rate*audio_data_width*audio_channel_num*2)-1) then
					bclk_div <= 0;
					bclk <= not bclk;
				else
					bclk_div <= bclk_div + 1;
				end if;
			end if;
		end if;
	end process;
	
	-- LR clock generator --
	process(CLK,nRESET)
	begin
		if (nReset = '0') then
			lrclk_div <= 0;
			lrclk <= '0';
		else
			if (rising_edge(CLK)) then
				if (lrclk_div >= audio_ref_clk/(audio_sample_rate*2)-1) then
					lrclk_div <= 0;
					lrclk <= not lrclk;
				else
					lrclk_div <= lrclk_div + 1;
				end if;
			end if;
		end if;
	
	end process;

end Behavior;