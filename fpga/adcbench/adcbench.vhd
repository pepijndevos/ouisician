library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity adcbench is
end;

architecture testbench of adcbench is

  signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal sndclk : std_logic := '0';

	signal data : std_logic := '0';
  signal word : signed(15 downto 0);

begin
  rst <= '1' after 20 ns;
  clk <= not clk after 10 ns;
  --data <= not data after 1 ms;
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok

  process(sndclk)
    variable counter: integer := 0;
  begin
    if rising_edge(sndclk) then
      counter := counter + 1;
      if counter = 20 then
        data <= '1';
      else
        data <= '0';
      end if;
    end if;
  end process;

  adc_inst: entity work.adc(behavioral)
    generic map (
      use_fir => true
    )
    port map (rst => rst,
      clk => clk,
      data => data,
      word => word);
end;
