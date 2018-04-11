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
		 GPIO_ADCDAT1: in std_logic;
		 GPIO_ADCDAT2: in std_logic;
		 GPIO_ADCCLK1: out std_logic;
		 GPIO_ADCCLK2: out std_logic;
		 AUD_ADCDAT  : in std_logic;
		 AUD_ADCLRCK : in std_logic;
		 AUD_BCLK    : in std_logic;
		 AUD_DACDAT  : out std_logic;
		 AUD_DACLRCK : in std_logic;
		 AUD_XCK     : out std_logic;
		 FPGA_I2C_SCLK: out std_logic;
		 FPGA_I2C_SDAT: inout std_logic;
		 potic       : out std_logic_vector(7 downto 0);
		 pot_clk     : out std_logic
	   );
end speaker;

architecture Behavioral of speaker is

	component pll is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic;         -- clk
			outclk_2 : out std_logic;         -- clk
			locked   : out std_logic
		);
	end component pll;
	
  signal counter : signed(31 downto 0);
  signal rst : std_logic;
	
  signal win1 : signed(15 downto 0);
  signal win2 : signed(15 downto 0);
  signal win3 : signed(15 downto 0);
  signal win4 : signed(15 downto 0);
  signal win56 : std_logic_vector(31 downto 0);
  
  signal mixed : signed(15 downto 0);
  
  signal wout1 : signed(15 downto 0);
  signal wout2 : signed(15 downto 0);

  
  signal sndclk : std_logic;
  signal sndclk2 : std_logic;
  signal sndclk3 : std_logic;

  signal bitclk : std_logic;
  signal adcclk : std_logic;
  signal clk : std_logic;

  signal Trem_out : signed(15 downto 0);
  signal flanger_fx : signed(15 downto 0);
  signal offset : unsigned(6 downto 0);
begin
GPIO_BCLK <= bitclk;
GPIO_ADCCLK1 <= adcclk;
GPIO_ADCCLK2 <= adcclk;

process(sndclk)
begin
	if rising_edge(sndclk) then
		counter <= counter+1;
		
		LEDR <= std_logic_vector(mixed(15 downto 6));
	end if;
end process;
--	Tremolo_inst : entity work.Tremolo_FX(behaviour)
--	port map(
--		data_in => mixed,
--		data_out => Trem_out,
--		CLK_50 => adcclk,
--		newValue => sndclk,
--		Trem_EN => Trem_EN,
--		reset => rst
--	);

  crossover_inst: entity work.Crossover(behaviour)
	port map (
      main_CLK => clk,
      Reset => rst,
      new_val => sndclk,
      data_in => flanger_fx,
      data_outlow => wout1,
		data_outhigh => wout2
		);
 
  comb_inst : entity work.comb(behavioral)
  generic map (
      bl_gain => 32,
      ff_gain => 0,
      fb_gain => 128
  ) port map (
    rst => rst,
    clk => clk,
    sndclk => sndclk,
    offset => x"3fff",
    word => mixed,
    resp => flanger_fx
  );

  triangle_inst : entity work.triangle
  generic map (
    width => 7,
	 speed => 2**16
) port map (
    rst => rst,
    clk => clk,
    data => offset
  );


  mixer_inst: entity work.mixer(behavioral)
    port map (rst => rst,
      clk => sndclk,
      word1 => win1,
      word2 => win2,
      word3 => win3,
      word4 => win4,
      word5 => signed(win56(31 downto 16)),
      word6 => signed(win56(15 downto 0)),
      resp => mixed);
		
		
  i2s_inst: entity work.i2s(behavioral)
    port map (rst => rst,
      bclk => bitclk,
      rlclk => GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => flanger_fx,
      win2 => flanger_fx,
      wout1 => win1,
      wout2 => win2);
		
--  adc_inst1: entity work.adc(behavioral)
--    port map (rst => rst,
--      clk => adcclk,
--		sndclk => sndclk2,
--      data => GPIO_ADCDAT1,
--      word => win3);
--		
--  adc_inst2: entity work.adc(behavioral)
--    port map (rst => rst,
--      clk => adcclk,
--		sndclk => sndclk3,
--      data => GPIO_ADCDAT2,
--      word => win4);
		
  normalization_inst : entity work.normalization(bhv)
	port map (
		clk50mhz => clk,
		pot_clk => pot_clk,
		reset => rst,
		KEY => KEY,
		ic => potic,
		amplification1 => 100,
		amplification2 => 100,
		amplification3 => 100,
		amplification4 => 100);  
  
	audio_inst : entity work.audio_interface(Behavorial)
		port map (
			LDATA => std_logic_vector(wout1),
			RDATA => std_logic_vector(wout2),
			clk => clk,
			Reset	=> rst,
			INIT_FINISH	=> open,
			adc_full	=> open,
			AUD_MCLK => AUD_XCK,
			AUD_ADCLRCK => AUD_ADCLRCK,
			AUD_ADCDAT => AUD_ADCDAT,
			AUD_BCLK => AUD_BCLK,
			data_over => sndclk,
			AUD_DACDAT => AUD_DACDAT,
			AUD_DACLRCK => AUD_DACLRCK,
			I2C_SDAT => FPGA_I2C_SDAT,
			I2C_SCLK => FPGA_I2C_SCLK,
			ADCDATA => win56
		);
	
	pll_inst: pll
		port map (
			refclk => CLOCK_50,
			rst => '0',
			outclk_0 => bitclk,  -- 1.536 MHz
			outclk_1 => clk, -- 49.152 MHz
			outclk_2 => adcclk, -- 49.152 MHz, was 24.576 MHz
			locked => rst);
			

end Behavioral;
