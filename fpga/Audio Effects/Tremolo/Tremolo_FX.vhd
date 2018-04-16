library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tremolo_FX is
generic(
	t_height : integer := 8
);
port(
	data_in : in signed(15 downto 0);
	data_out : out signed(15 downto 0);
	CLK_50 : in std_logic;
	newValue : in std_logic;
	reset : in std_logic;
	filterid: IN std_logic_vector(7 DOWNTO 0);
	chan: IN std_logic_vector(7 DOWNTO 0);
	fil_data: IN std_logic_vector(31 DOWNTO 0)
);
end Tremolo_FX;

architecture behaviour of Tremolo_FX is
signal CLK_3HZ : std_logic := '0';
signal t_waveout : signed(2*t_height-1 downto 0) := (others=>'0');
signal data_out_temp : signed(t_waveout'length+data_in'length-1 downto 0):= (others=>'0');
constant max_range : integer := (2**t_height-1)-1;
signal counter_int :  integer := 10000;
signal Trem_EN : std_logic := '0';
begin

--Counter for different frequencies
process(CLK_50,Reset) -- 4.91 Hz, 1000 count : 49.1 Hz
variable counter : integer := 0;
begin
if (Reset = '0') then
	counter := 0;
	CLK_3HZ <= '0';
elsif(rising_edge(CLK_50)) then
	counter := counter + 1;
	if (counter = Counter_int ) then 
		CLK_3HZ <= NOT CLK_3HZ;
		counter := 0;
	end if;
end if;
end process;

--Triangle wave generation
process(CLK_3HZ,Reset) 
variable counter : integer := 0;
variable direction: std_logic := '0';
begin
if (Reset = '0') then
	counter := 0;
	t_waveout <= (others =>'0');
elsif (rising_edge(CLK_3HZ)) then
	if (direction = '0') then
		counter := counter + 1;
		t_waveout <= to_signed(counter,t_waveout'LENGTH);
		if(counter = 2**t_height -1) then
			direction := '1';
		end if;
	end if;
	if(direction = '1') then
		counter := counter -1;
		t_waveout <= to_signed(counter,t_waveout'LENGTH);
		if(counter = 0) then
			direction := '0';
		end if;
	end if;
end if;
end process;

-- Multiplying Carrier freq with data input

process(CLK_50,Reset)
begin
if (Reset = '0') then
	data_out <= (others =>'0');
	Trem_EN <= '0';
elsif(rising_edge(CLK_50)) then
	IF filterid(7 DOWNTO 0) = "00010100" AND chan(2 DOWNTO 0) = "001" THEN --range value spi
		Counter_int <= to_integer(signed(fil_data));
	elsif filterid(7 downto 0) = "00010011" and chan(2 downto 0) = "001" then -- on off range value
		if fil_data(0) =  '1' then
			Trem_EN <= '1';
		elsif fil_data(0) = '0' then
			Trem_EN <= '0';
		end if;
	END IF;
	if (Trem_EN = '1') then
			data_out_temp <= resize(t_waveout*data_in,data_out_temp'LENGTH);
			data_out<= resize(data_out_temp/(2**(9)),data_out'LENGTH); --previous is set to 10 length.
	else
		data_out <= data_in;
	end if;
end if;
end process;
end behaviour;
