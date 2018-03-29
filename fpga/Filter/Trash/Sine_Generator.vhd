LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL; 

entity Sine_Gen is
port (CLK : in STD_LOGIC;
		sine_out : out signed(15 downto 0);
		newCLK : out STD_LOGIC;
		reset : in STD_LOGIC
);
end Sine_Gen;

architecture behaviour of Sine_Gen is
signal nCLK : std_logic := '0';
signal i : integer range 0 to 30 := 0;
type memory is array (0 to 29) of integer range -32768 to 32767;
signal sine : memory := (0,6813,13328,19260,24351,28377,31163,32587,32587,31163,28377,
24351,19260,13328,6813,0,-6813,-13328,-19260,-24351,-28377,-31163,-32587,-32587,-31163,
-28377,-24351,-19260,-13328,-6813);

begin
process(CLK,reset) --new clock generation
variable counter : integer := 0;
begin
if(reset ='0') then 
	counter := 0;
	nCLK <= '0';
elsif (rising_edge(CLK)) then
	counter := counter+1;
	if(counter = 11110) then
		nCLK <= not(nCLK);
		counter := 0;
	end if;
end if;
newCLK<=nCLK;
end process;
 
process (nCLK) 
begin
if rising_edge(nCLK) then
	sine_out <= to_signed(sine(i),sine_out'Length);
	i <= i+1;
	if(i=29) then
		i<= 0;
	end if;
end if;
end process;
end behaviour;
