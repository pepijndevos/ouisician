library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity Sine_tb is
end;


architecture tb of sine_tb is
signal clk: std_logic :='0';
signal resp: signed(15 downto 0);
signal new_clk : std_logic := '0';
signal reset_sig :std_logic := '1';

component Sine_Gen
port (CLK : in STD_LOGIC;
		sine_out : out signed(15 downto 0);
		newCLK : out STD_LOGIC;
		reset : in STD_LOGIC
);
end component;
begin
clk <= not clk after 10ns; --50Mhz clk


input_signal : Sine_Gen port map(
	CLK => clk,
	sine_out => resp,
	newCLK => new_clk,
	reset => reset_sig
); 


end;
