library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity impulsebench is
end;

architecture testbench of impulsebench is

signal clk : std_logic := '0';
signal sndclk : std_logic := '0';
signal reset : std_logic :='1';
signal led_signal : std_logic := '0';


component flashing_light
	PORT (clk, reset : IN std_logic;
			led : OUT std_logic);
end component;

begin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok


test_label:flashing_light port map (
	clk => clk, 
	reset => '1',
	led => led_signal
	
);


--input_signal : Sine_Gen port map(
--	CLK => clk,
--	sine_out => ,
--	newCLK => new_clk,
--	reset => reset_sig
--); 
end;
