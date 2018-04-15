library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IIRDF1_TB is
end entity IIRDF1_TB;

architecture behavior of IIRDF1_TB is
    -- define clock period here
    constant cp: time := 20 ns;
	 constant cs: time := 20.83 us;

component WahWah_FX is
port (
	CLK_50		: in std_logic;
	nReset		: in std_logic;
	new_val		: in std_logic;       -- indicates a new input value, input from data_over
	data_in		: in signed (15 downto 0);         
	data_out		: out signed (15 downto 0);   -- Output
	WahWah_EN 	: in std_logic
);
end component;
    
signal nclk     :   std_logic := '0';
signal nreset   :   std_logic := '0';
signal nValue   :   signed(15 downto 0) :=(others =>'0');
signal sndclk  : 	std_logic := '0';
signal resp : signed(15 downto 0)  := (others =>'0');
signal strobe : std_logic:='0';
signal i : integer range 0 to 960 := 0;
constant arr_size : integer := 23;
type memory is array (0 to arr_size) of integer range -32768 to 32767;
signal sine : memory := (0,33,63,90,110,123,127,123,110,90,64,33,0,-33,-63,-90,-110,-123,-127,-123,-110,-90,-64,-33
);

signal WahWah_EN : std_logic := '0';
signal new_CLK : std_logic := '0';
begin
nclk  <= not nclk after cp/2;
nreset <= '0', '1' after 100*cp;
sndclk <= NOT sndclk AFTER 20.83 us;
WahWah_EN <= '1' after 50 ms;


process(nclk,sndclk)
begin
if(rising_edge(nclk)) then
	if(rising_edge(sndclk)) then
		strobe <= '1';
	else
		strobe <= '0';
	end if;
end if;
end process;


--process(sndCLK)
--variable counter : integer := 0;
--begin
--if (rising_edge(sndCLK)) then
--counter := counter +1;
--	if counter = 100 then
--		nValue <= x"3fff";
--	else 
--		nValue <= x"0000";
--	end if;
--end if;
--end process;

--sine wave generation

process(nclk,nreset) -- 4.91 Hz, 1000 count : 49.1 Hz
variable counter : integer := 0;
begin
if (nreset= '0') then
	counter := 0;
	new_CLK <= '0';
elsif(rising_edge(nclk)) then
	counter := counter + 1;
	if (counter = 30 ) then 
		new_CLK <= NOT new_CLK;
		counter := 0;
	end if;
end if;
end process;

process (sndclk) 
begin
if rising_edge(sndclk) then
	nValue <= to_signed(sine(i),nValue'Length);
	i <= i+1;
	if(i=arr_size) then
		i<= 0;
	end if;
end if;
end process;

testbed : WahWah_FX
port map(
	CLK_50 => nclk,	
	nReset => nreset,		
	new_val =>	strobe,	
	data_in =>	nValue,	    
	data_out =>	open,	
	WahWah_EN =>'1'    
);
end architecture;

