library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity adcbench is
end;

architecture testbench of adcbench is

  signal rst : std_logic := '0';
	signal clk : std_logic := '0';

	signal data : std_logic := '0';
  signal word : signed(15 downto 0);

begin
  rst <= '1' after 20 ns;
  clk <= not clk after 10 ns;
  data <= not data after 20 ns;

  adc_inst: entity work.adc(behavioral)
    port map (rst => rst,
      clk => clk,
      data => data,
      word => word);
end;
