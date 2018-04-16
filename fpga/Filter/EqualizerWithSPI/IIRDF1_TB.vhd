library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IIRDF1_TB is
end entity IIRDF1_TB;

architecture behavior of IIRDF1_TB is
    -- define clock period here
    constant cp: time := 20 ns;
	 constant cs: time := 20.83 us;

component IIRDF1EQ is
generic(
--    W_in : integer := 16;
--	 W_coef : integer := 30;   
--    B0_low : integer := 706; 
--    B1_low : integer := 1411;
--    B2_low : integer := 706;
--    A0_low : integer := 4194304;
--    A1_low : integer := -8233335;
--    A2_low : integer := 4041854; 
--
--    B0_high : integer 	:= 4117373; 
--    B1_high: integer 	:= -8234746;
--    B2_high: integer 	:= 4117373;
--    A0_high : integer 	:= 4194304;
--    A1_high: integer 	:= -8233335;
--    A2_high : integer 	:= 4041854
   	W_in : integer ;
	W_coef : integer  
);
    port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0);   -- Output
	chanFIL : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridFIL : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataFIL : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	A0port : in STD_LOGIC_VECTOR(23 DOWNTO 0); 
	A1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	coefficientFLAG : in STD_LOGIC
    );
end component;
    
signal nclk     :   std_logic := '0';
signal nreset   :   std_logic := '0';
signal nValue   :   signed(15 downto 0) :=(others =>'0');
signal sndclk  : 	std_logic := '0';
signal resp : signed(15 downto 0)  := (others =>'0');
signal strobe : std_logic:='0';
signal wtf : std_logic_vector(7 DOWNTO 0);
signal wtf2 : std_logic_vector(31 DOWNTO 0);
signal wtf1 : signed(15 DOWNTO 0);
signal i : integer range 0 to 960 := 0;
type memory is array (0 to 959) of integer range -32768 to 32767;
signal sine : memory := (0,1,2,2,3,4,5,6,7,7,8,9,10,11,12,12,13,14,15,16,17,17,18,19,20,21,22,22,23,24,25,26,26,27,28,29,30,30,31,32,33,34,34,35,36,37,38,38,39,40,41,42,42,43,44,45,46,46,47,48,49,49,50,51,52,52,53,54,55,55,56,57,58,58,59,60,61,61,62,63,63,64,65,66,66,67,68,68,69,70,71,71,72,73,73,74,75,75,76,77,77,78,79,79,80,81,81,82,82,83,84,84,85,86,86,87,87,88,89,89,90,90,91,92,92,93,93,94,94,95,95,96,97,97,98,98,99,99,100,100,101,101,102,102,103,103,104,104,105,105,106,106,107,107,107,108,108,109,109,110,110,110,111,111,112,112,112,113,113,114,114,114,115,115,115,116,116,116,117,117,117,118,118,118,119,119,119,119,120,120,120,121,121,121,121,122,122,122,122,122,123,123,123,123,123,124,124,124,124,124,125,125,125,125,125,125,125,126,126,126,126,126,126,126,126,126,126,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,126,126,126,126,126,126,126,126,126,126,125,125,125,125,125,125,125,124,124,124,124,124,123,123,123,123,123,122,122,122,122,122,121,121,121,121,120,120,120,119,119,119,119,118,118,118,117,117,117,116,116,116,115,115,115,114,114,114,113,113,112,112,112,111,111,110,110,110,109,109,108,108,107,107,107,106,106,105,105,104,104,103,103,102,102,101,101,100,100,99,99,98,98,97,97,96,95,95,94,94,93,93,92,92,91,90,90,89,89,88,87,87,86,86,85,84,84,83,82,82,81,81,80,79,79,78,77,77,76,75,75,74,73,73,72,71,71,70,69,68,68,67,66,66,65,64,64,63,62,61,61,60,59,58,58,57,56,55,55,54,53,52,52,51,50,49,49,48,47,46,46,45,44,43,42,42,41,40,39,38,38,37,36,35,34,34,33,32,31,30,30,29,28,27,26,26,25,24,23,22,22,21,20,19,18,17,17,16,15,14,13,12,12,11,10,9,8,7,7,6,5,4,3,2,2,1,0,-1,-2,-2,-3,-4,-5,-6,-7,-7,-8,-9,-10,-11,-12,-12,-13,-14,-15,-16,-17,-17,-18,-19,-20,-21,-22,-22,-23,-24,-25,-26,-26,-27,-28,-29,-30,-30,-31,-32,-33,-34,-34,-35,-36,-37,-38,-38,-39,-40,-41,-42,-42,-43,-44,-45,-46,-46,-47,-48,-49,-49,-50,-51,-52,-52,-53,-54,-55,-55,-56,-57,-58,-58,-59,-60,-61,-61,-62,-63,-64,-64,-65,-66,-66,-67,-68,-68,-69,-70,-71,-71,-72,-73,-73,-74,-75,-75,-76,-77,-77,-78,-79,-79,-80,-81,-81,-82,-82,-83,-84,-84,-85,-86,-86,-87,-87,-88,-89,-89,-90,-90,-91,-92,-92,-93,-93,-94,-94,-95,-95,-96,-97,-97,-98,-98,-99,-99,-100,-100,-101,-101,-102,-102,-103,-103,-104,-104,-105,-105,-106,-106,-107,-107,-107,-108,-108,-109,-109,-110,-110,-110,-111,-111,-112,-112,-112,-113,-113,-114,-114,-114,-115,-115,-115,-116,-116,-116,-117,-117,-117,-118,-118,-118,-119,-119,-119,-119,-120,-120,-120,-121,-121,-121,-121,-122,-122,-122,-122,-122,-123,-123,-123,-123,-123,-124,-124,-124,-124,-124,-125,-125,-125,-125,-125,-125,-125,-126,-126,-126,-126,-126,-126,-126,-126,-126,-126,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-126,-126,-126,-126,-126,-126,-126,-126,-126,-126,-125,-125,-125,-125,-125,-125,-125,-124,-124,-124,-124,-124,-123,-123,-123,-123,-123,-122,-122,-122,-122,-122,-121,-121,-121,-121,-120,-120,-120,-119,-119,-119,-119,-118,-118,-118,-117,-117,-117,-116,-116,-116,-115,-115,-115,-114,-114,-114,-113,-113,-112,-112,-112,-111,-111,-110,-110,-110,-109,-109,-108,-108,-107,-107,-107,-106,-106,-105,-105,-104,-104,-103,-103,-102,-102,-101,-101,-100,-100,-99,-99,-98,-98,-97,-97,-96,-95,-95,-94,-94,-93,-93,-92,-92,-91,-90,-90,-89,-89,-88,-87,-87,-86,-86,-85,-84,-84,-83,-82,-82,-81,-81,-80,-79,-79,-78,-77,-77,-76,-75,-75,-74,-73,-73,-72,-71,-71,-70,-69,-68,-68,-67,-66,-66,-65,-64,-64,-63,-62,-61,-61,-60,-59,-58,-58,-57,-56,-55,-55,-54,-53,-52,-52,-51,-50,-49,-49,-48,-47,-46,-46,-45,-44,-43,-42,-42,-41,-40,-39,-38,-38,-37,-36,-35,-34,-34,-33,-32,-31,-30,-30,-29,-28,-27,-26,-26,-25,-24,-23,-22,-22,-21,-20,-19,-18,-17,-17,-16,-15,-14,-13,-12,-12,-11,-10,-9,-8,-7,-7,-6,-5,-4,-3,-2,-2,-1
);

constant    W_in 	 : integer := 16;
constant    W_coef : integer := 18;   
constant    B0_base : integer := 4185; 
constant    B1_base : integer := -7958;
constant    B2_base : integer := 3792;
constant    A0_base : integer := 4096;
constant    A1_base : integer := -7965;
constant    A2_base : integer := 3875;

constant    B0_mid : integer := 4874;
constant    B1_mid : integer := -5929;
constant    B2_mid : integer := 2599;
constant    A0_mid : integer := 4096;
constant    A1_mid : integer := -5929;
constant    A2_mid : integer := 3377;

constant    B0_high : integer := 8823; 
constant    B1_high : integer := -8557;
constant    B2_high : integer := 3650;
constant    A0_high : integer := 4096;
constant    A1_high : integer := -1367;
constant    A2_high : integer := 1187;

begin
    nclk                <= not nclk after cp/2;
    nreset              <= '0', '1' after 100*cp;
  	 sndclk <= NOT sndclk AFTER 20.83 us;

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

process(sndCLK)
variable counter : integer := 0;
begin
if (rising_edge(sndCLK)) then
counter := counter +1;
	if counter = 100 then
		nValue <= x"1fff";
	--else 
	--	nValue <= x"0000";
	end if;
end if;
end process;

--sine wave generation
--process (sndclk) --either this or impulse
--begin
--if rising_edge(sndclk) then
--	nValue <= to_signed(sine(i),nValue'Length);
--	i <= i+1;
--	if(i=959) then
--		i<= 0;
--	end if;
--end if;
--end process;

testbed : IIRDF1EQ
generic map(
    W_in => W_in,
	W_coef => W_coef   

)
port map(
	iCLK => nclk,   
	iRESET_N => nreset,
	new_val => strobe,
	IIR_in => nValue,              
	IIR_out => resp,
	chanFIL => open,
	filteridFIL => open,
	filterdataFIL => open,
	A0port => open ,
	A1port => open,
	A2port => open,
	B0port => open,
	B1port => open,
	B2port => open,
	coefficientFLAG => open
);
end architecture;

