library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity speaker is
  port(CLOCK_50    : in std_logic;
		 LEDR        : out std_logic_vector(9 downto 0);
		 KEY			 : in std_logic_vector(3 downto 0);
		 GPIO_DIN    : in std_logic;
		 GPIO_LRCK   : out std_logic;
		 GPIO_BCLK   : out std_logic;
		 GPIO_DOUT   : out std_logic;
		 GPIO_ADCDAT : in std_logic;
		 GPIO_ADCCLK : in std_logic
	   );
end speaker;

architecture Behavioral of speaker is

	component pll is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic         -- clk
		);
	end component pll;
	
  signal counter : signed(31 downto 0);
  signal rst : std_logic;
	
  signal win1 : signed(15 downto 0);
  signal win2 : signed(15 downto 0);
  signal win3 : signed(15 downto 0);
  signal wout : signed(31 downto 0);
  
  signal sndclk : std_logic;
  signal bitclk : std_logic;
  signal adcclk : std_logic;
begin
rst <= KEY(0);
GPIO_BCLK <= bitclk;

process(sndclk)
begin
	if rising_edge(sndclk) then
		counter <= counter+1;
		
		LEDR <= std_logic_vector(win2(15 downto 6));
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
      bclk => bitclk,
      rlclk => GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => win1,
      win2 => win3,
      wout1 => wout(31 downto 16),
      wout2 => wout(15 downto 0));
		
  adc_inst: entity work.adc(behavioral)
    port map (rst => rst,
      clk => adcclk,
		sndclk => sndclk,
      data => GPIO_ADCDAT,
      word => win2);
	
	pll_inst: pll
		port map (
			refclk => CLOCK_50,
			rst => rst,
			outclk_0 => bitclk,
			outclk_1 => adcclk);
			

end Behavioral;