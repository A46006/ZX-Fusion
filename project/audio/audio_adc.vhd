library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_adc is
	port (
		CLK			:	in	std_logic;
		nRESET		:	in	std_logic;
		ADC_DAT		:	in std_logic;
		
		EAR		:	out std_logic
	);
end audio_adc;

architecture Behavior of audio_adc is
	constant audio_codec_size : integer := 24;
	signal shift_reg : std_logic_vector((audio_codec_size-1) downto 0) := (others => '0');
	signal counter : integer range 0 to audio_codec_size := 0;
begin
	EAR <= shift_reg(audio_codec_size-1);
	
	process(CLK, nRESET)
	begin
		if (nRESET = '0') then
			shift_reg <= (others => '0');
		else
			if (rising_edge(CLK)) then
				if (counter < audio_codec_size) then
					shift_reg(counter) <= ADC_DAT;
					counter <= counter + 1;
				else
					shift_reg(audio_codec_size-2 downto 0) <= (others => '0');
					counter <= 0;
				end if;
			end if;
		end if;
	
	end procesS;

end Behavior;