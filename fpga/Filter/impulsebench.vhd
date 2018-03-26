library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity impulsebench is
end;

architecture testbench of impulsebench is

signal clk : std_logic := '0';
signal sndclk : std_logic := '0';
signal word : signed(15 downto 0);
signal resp : signed(15 downto 0);
signal reset : std_logic :='1';
signal sine_in : signed(15 downto 0);

signal i : integer range 0 to 30 := 0;
type memory is array (0 to 29) of integer range -32768 to 32767;
signal sine : memory := (0,6813,13328,19260,24351,28377,31163,32587,32587,31163,28377,
24351,19260,13328,6813,0,-6813,-13328,-19260,-24351,-28377,-31163,-32587,-32587,-31163,
-28377,-24351,-19260,-13328,-6813);
  
component IIR
Generic (
    w_in : integer := 16;
    QFORMAT: integer:= 30; --Q2.30 format
    
    B0 : real := 0.00009506; 
    B1 : real := 0.00019012;
    B2 : real := 0.00009506;
    A1 : real := -1.97223373;
    A2 : real := 0.972613969;
    A0 : real := 1.0
);
Port ( iCLK : in STD_LOGIC;
	    sCLK : in STD_LOGIC;
       Reset : in STD_LOGIC;
       IIR_in : in SIGNED(w_in-1 downto 0);
       IIR_out : out SIGNED(w_in-1 downto 0)
);
end component;

--component Sine_Gen
-- 	port (CLK : in STD_LOGIC;
--			sine_out : out SIGNED(15 downto 0)
--);
--end component;



begin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok

process (sndclk) --either this or impulse
begin
if rising_edge(sndclk) then
	word <= to_signed(sine(i),word'Length);
	i <= i+1;
	if(i=29) then
		i<= 0;
	end if;
end if;
end process;

--  process(sndclk) --impulse response
--    variable counter: integer := 0;
--  begin
--    if rising_edge(sndclk) then
--      counter := counter + 1;
--      if counter = 10 then
--        word <= x"3fff";
--      else
--        word <= x"0000";
--      end if;
--    end if;
--  end process;

filter_inst : IIR port map (
	sCLK => sndclk,
	iCLK => clk,
   IIR_in => word,
	IIR_out => resp,
	Reset => reset
);


--input_signal : Sine_Gen port map(
--	CLK => clk,
--	sine_out => ,
--	newCLK => new_clk,
--	reset => reset_sig
--); 
end;
