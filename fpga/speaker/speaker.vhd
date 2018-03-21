library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity speaker is
  port(CLOCK_50    : in std_logic;
		 LEDR        : out std_logic_vector(9 downto 0);
		 GPIO_DIN    : in std_logic;
		 GPIO_LRCK   : in std_logic;
		 GPIO_BCLK   : in std_logic;
		 GPIO_DOUT   : out std_logic
	   );
end speaker;

architecture Behavioral of speaker is
	signal counter : signed(31 downto 0);
	
  signal win : signed(63 downto 0);
  signal wout : signed(63 downto 0);
begin

process(GPIO_LRCK)
begin
	if rising_edge(GPIO_LRCK) then
		counter <= counter+1;
		LEDR <= std_logic_vector(wout(15 downto 6));
		
		--win <= wout; -- ECHO
	end if;
end process;

  i2s_inst: entity work.i2s(behavioral)
    port map (rst => '1',
      bclk => GPIO_BCLK,
      rlclk =>GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => counter(15 downto 0),
      win2 => x"00ff",
      win3 => x"5555",
      win4 => x"5555",
      wout1 => wout(63 downto 48),
      wout2 => wout(47 downto 32),
      wout3 => wout(31 downto 16),
      wout4 => wout(15 downto 0));

end Behavioral;