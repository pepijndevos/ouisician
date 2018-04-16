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
	filterid: IN std_logic_vector(7 DOWNTO 0);
	chan: IN std_logic_vector(7 DOWNTO 0);
	fil_data: IN std_logic_vector(31 DOWNTO 0)
);
end entity Distortion_FX;

architecture behaviour of Distortion_FX is

signal Distortion_EN : std_logic:='0';
signal clip_setting : integer := 16000;
signal data_out_temp : signed(15 downto 0):= (others =>'0'); 
begin

process(clk_50,nReset)
begin
if(rising_edge(clk_50)) then
	IF filterid(7 DOWNTO 0) = "00010010"  AND chan(2 DOWNTO 0) = "001" THEN --range value spi
		clip_setting <= to_integer(signed(fil_data)); -- will spi data be signed?
	END IF;
end if;
end process;

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
	if Distortion_EN = '0' then
		data_out <= data_in;
	elsif Distortion_EN = '1' then
		data_out <= data_out_temp;
	end if;
end if;
end process;

end;