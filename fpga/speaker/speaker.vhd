library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity speaker is
  port(CLOCK_50    : in std_logic;
		 LEDR        : out std_logic_vector(9 downto 0);
		 KEY			 : in std_logic_vector(3 downto 0);
		 GPIO_DIN    : in std_logic;
		 GPIO_LRCK   : in std_logic;
		 GPIO_BCLK   : in std_logic;
		 GPIO_DOUT   : out std_logic;
		 GPIO_ADCDAT : in std_logic;
		 GPIO_ADCCLK : in std_logic
	   );
end speaker;

architecture Behavioral of speaker is
  signal counter : signed(31 downto 0);
  signal rst : std_logic;
	
  signal win1 : signed(15 downto 0);
  signal win2 : signed(15 downto 0);
  signal win3 : signed(15 downto 0);
  signal wout : signed(63 downto 0);
  
  signal clk : std_logic;
begin
rst <= KEY(0);

process(GPIO_ADCCLK)
	variable adcounter : signed(31 downto 0);
begin
	if rising_edge(GPIO_ADCCLK) then
		LEDR <= std_logic_vector(win2(15 downto 6));
	end if;
end process;

process(GPIO_LRCK)
begin
	if rising_edge(GPIO_LRCK) then
		counter <= counter+1;
		
		win3 <= win2;
		
		if KEY(0) = '0' then
		  win1 <= counter(5 downto 0) & "0000000000";
		elsif KEY(1) = '0' then
		  win1 <= counter(6 downto 0) & "000000000";
		elsif KEY(2) = '0' then
		  win1 <= counter(7 downto 0) & "00000000";
		elsif KEY(3) = '0' then
		  win1 <= counter(8 downto 0) & "0000000";
	   else
		  win1 <= x"0000";
		end if;
	end if;
end process;

  i2s_inst: entity work.i2s(behavioral)
    port map (rst => rst,
      bclk => GPIO_BCLK,
      rlclk =>GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => win1,
      win2 => x"00ff",
      win3 => win3,
      win4 => x"5555",
      wout1 => wout(63 downto 48),
      wout2 => wout(47 downto 32),
      wout3 => wout(31 downto 16),
      wout4 => wout(15 downto 0));
		
  adc_inst: entity work.adc(behavioral)
    port map (rst => rst,
      clk => GPIO_ADCCLK,
      data => GPIO_ADCDAT,
      word => win2);

end Behavioral;