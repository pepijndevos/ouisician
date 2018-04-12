library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Distortion_FX is
port (
	CLK_50		: in std_logic;
	nReset		: in std_logic;
	new_val		: in std_logic;       -- indicates a new input value, input from data_over
	data_in		: in signed (15 downto 0);         
	data_out		: out signed (15 downto 0);   -- Output
	Distortion_EN 	: in std_logic
);
end entity Distortion_FX;

architecture behaviour of Distortion_FX is
constant clip_setting : integer := 3000;
signal data_out_temp : signed(15 downto 0); 
begin

process(clk_50,nReset)
begin
if  nReset = '0' then
	data_out_temp <= (others=>'0');
elsif (rising_edge(clk_50)) then
	if data_in >= clip_setting then
		data_out_temp <= to_signed(clip_setting,data_out_temp'LENGTH);
	elsif data_in <= -clip_setting then
		data_out_temp <= to_signed(-clip_setting,data_out_temp'LENGTH);
	else
		data_out_temp <= data_in;
	end if;
end if;
end process;

process(CLK_50,nReset)
begin
if nReset = '0' then
	data_out <= (others => '0');
elsif(rising_edge(CLK_50)) then
	if(new_val = '1') then
	if Distortion_EN = '0' then
		data_out <= data_in;
	elsif Distortion_EN = '1' then
		data_out <= shift_right(data_out_temp,1);
	end if;
	end if;
end if;
end process;

end;