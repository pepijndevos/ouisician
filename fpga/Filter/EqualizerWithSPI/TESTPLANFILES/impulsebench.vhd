library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IIRDF1_TB is
end entity IIRDF1_TB;

architecture behavior of IIRDF1_TB is
    -- define clock period here
    constant cp: time := 20 ns;
	 constant cs: time := 20.83 us;

component IIRDF1 is
generic(
    W_in : integer := 16;
	 W_coef : integer := 30; 
-- HIGH
    B0 : integer := 23500; 
    B1 : integer := -15821;
    B2 : integer := 7983;
    A0 : integer := 16384;
    A1 : integer := -5469;
    A2 : integer := 4748 
-- MID
--    B0 : integer := 17504; 
--    B1 : integer := 17504;
--    B2 : integer := 12387;
--    A0 : integer := 16384;
--    A1 : integer := -23714;
--    A2 : integer := 13507 
-- LOW  
--    B0 : integer := 16536; 
--    B1 : integer := -31849;
--    B2 : integer := 15356;
--    A0 : integer := 16384;
--    A1 : integer := -31858;
--    A2 : integer := 15499 
--
--    B0_high : integer 	:= 4117373; 
--    B1_high: integer 	:= -8234746;
--    B2_high: integer 	:= 4117373;
--    A0_high : integer 	:= 4194304;
--    A1_high: integer 	:= -8233335;
--    A2_high : integer 	:= 4041854
);
    port (
iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;
    
signal nclk     :   std_logic := '0';
signal nreset   :   std_logic := '0';
signal nValue   :   signed(15 downto 0) :=(others =>'0');
signal sndclk  : 	std_logic := '0';
signal resp : signed(15 downto 0)  := (others =>'0');
signal strobe : std_logic:='0';
signal new_CLK : std_logic := '0';
signal i : integer range 0 to 48 := 0; -- change this for different frequencies
type memory is array (0 to 48) of integer range -200 to 200; -- change this for differnt frequencies

signal sine : memory := (0,17,33,49,63,77,90,101,110,117,123,126,127,126,123,117,110,101,90,77,64,49,33,17,0,-17,-33,-49,-63,-77,-90,-101,-110,-117,-123,-126,-127,-126,-123,-117,-110,-101,-90,-77,-64,-49,-33,-17,0
); -- 5kHz

--constant 	W_in 	 : integer := 16;
--constant	W_coef : integer := 30;   
--constant    B0_low : integer := 706; 
--constant    B1_low : integer := 1411;
--constant    B2_low : integer := 706;
--constant    A0_low : integer := 4194304;
--constant    A1_low : integer := -8233335;
--constant    A2_low : integer := 4041854; 
--
--constant    B0_high : integer := 4117373; 
--constant    B1_high : integer := -8234746;
--constant    B2_high : integer := 4117373;
--constant    A0_high : integer := 4194304;
--constant    A1_high : integer := -8233335;
--constant    A2_high : integer := 4041854;
--
begin
    nclk                <= not nclk after cp/2;
    nreset              <= '0', '1' after 100*cp;
  	 sndclk <= NOT sndclk AFTER 5.71 us; -- 1/sCLK in matlab

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

process(nclk,nreset) -- 4.91 Hz, 1000 count : 49.1 Hz
variable counter : integer := 0;
begin
if (nreset= '0') then
	counter := 0;
	new_CLK <= '0';
elsif(rising_edge(nclk)) then
	counter := counter + 1;
	if (counter = 32 ) then 
		new_CLK <= NOT new_CLK;
		counter := 0;
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
process(new_CLK) --either this or impulse
begin
if rising_edge(new_CLK) then
	nValue <= to_signed(sine(i),nValue'Length);
	i <= i+1;
	if(i=47) then
		i<= 0;
	end if;
end if;
end process;

testbed : IIRDF1
port map(
      iCLK => nclk,      
      iRESET_N =>nreset ,      
      new_val => strobe,       
      IIR_in => nValue,              
      IIR_out => open
);
end architecture;


