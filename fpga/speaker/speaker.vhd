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
		 pot_clk     : out std_logic;
		 
		 
		dig0	: OUT std_logic_vector(6 DOWNTO 0); 
		dig1	: OUT std_logic_vector(6 DOWNTO 0); 
		dig2	: OUT std_logic_vector(6 DOWNTO 0); 
		dig3	: OUT std_logic_vector(6 DOWNTO 0); 
		dig4	: OUT std_logic_vector(6 DOWNTO 0); 
		dig5 	: OUT std_logic_vector(6 DOWNTO 0);
		
		SW : in std_logic_vector(9 downto 0);
		
		--FROM MASTER
		sclk	: IN STD_LOGIC;  --spi clk from master	
		ss	: IN STD_LOGIC;  --active low slave select
		mosi	: IN STD_LOGIC;  --master out, slave in
		--TO MASTER
		miso	: out STD_LOGIC := 'Z'  --master in, slave out
		
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
  signal pi1 : signed(15 downto 0);
  signal pi2 : signed(15 downto 0);
  signal myadc1 : signed(15 downto 0);
  signal myadc2 : signed(15 downto 0);
  signal socadc : std_logic_vector(31 downto 0);
  
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
  signal offset : unsigned(15 downto 0);
  
  	signal EQ_out : signed(15 downto 0):= (others=>'0');
	signal chan_temp :  STD_LOGIC_VECTOR(7 DOWNTO 0); 
	signal filterid_temp :  STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal filterdata_temp :  STD_LOGIC_VECTOR(31 DOWNTO 0); 
	
	signal data_in_temp : signed(15 downto 0):= (others=>'0');
	signal ADCDATA : std_logic_vector(31 downto 0) := (others=>'0');
	signal LDATA : std_logic_vector(15 downto 0);
	signal RDATA : std_logic_vector(15 downto 0);
	signal data_over_temp : std_logic := '0';
	
begin
GPIO_BCLK <= bitclk;
GPIO_ADCCLK1 <= adcclk;
GPIO_ADCCLK2 <= adcclk;

win1 <= myadc1 when SW(1) = '1' else signed(socadc(31 downto 16));
win2 <= myadc2 when SW(1) = '1' else signed(socadc(15 downto 0));


process(sndclk)
begin
	if rising_edge(sndclk) then
		counter <= counter+1;
		LEDR <= std_logic_vector(mixed(15 downto 6));
	end if;
end process;
Tremolo_inst : entity work.Tremolo_FX(behaviour)
port map(
	data_in => mixed,
	data_out => Trem_out,
	CLK_50 => adcclk,
	newValue => sndclk,
	reset => rst,
	chan => chan_temp, 
	filterid => filterid_temp,
	fil_data => filterdata_temp
);

  crossover_inst: entity work.Crossover
	port map (
      main_CLK => clk,
      Reset => rst,
      new_val => sndclk,
      data_in => Trem_out,
      data_outlow => wout1,
		data_outhigh => wout2
		);
		
  comb_inst : entity work.comb(behavioral)
	port map (
	  rst => rst,
    clk => clk,
    sndclk => sndclk,
    bl_gain => 0,
    ff_gain1 => 255,
    fb_gain1 => 0,
    ff_gain2 => 0,
    fb_gain2 => 0,
    ff_gain3 => 0,
    fb_gain3 => 0,
    offset1 => resize(offset+256, 20),
    offset2 => resize(offset+256, 20),
    offset3 => resize(offset+256, 20),
    word => mixed,
    resp => flanger_fx
  );


  triangle_inst : entity work.triangle
  port map (
    max_ampl => x"03ff",
	 speed => x"03ff",
    rst => rst,
    clk => clk,
    data => offset
  );


  mixer_inst: entity work.mixer
    port map (rst => rst,
      clk => sndclk,
      word1 => win1,
      word2 => win2, -- set to 0 for 
      word3 => pi1,
      word4 => pi2,
      resp => mixed);
		
		
  i2s_inst: entity work.i2s
    port map (rst => rst,
      bclk => bitclk,
      rlclk => GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => flanger_fx,
      win2 => flanger_fx,
      wout1 => pi1,
      wout2 => pi2);

  adc_inst1: entity work.adc(behavioral)
    generic map (
      use_fir => false
    )
    port map (rst => rst,
      clk => adcclk,
		sndclk => sndclk2,
      data => GPIO_ADCDAT1,
      word => myadc1);
		
  adc_inst2: entity work.adc(behavioral)
    generic map (
      use_fir => false
	 )
    port map (rst => rst,
      clk => adcclk,
		sndclk => sndclk3,
      data => GPIO_ADCDAT2,
      word => myadc2);
		
  normalization_inst : entity work.normalization
	port map (
		clk50mhz => clk,
		pot_clk => pot_clk,
		reset => rst,
		KEY => KEY,
		ic => potic,
		chan => chan_temp, 
		filterid => filterid_temp,
		fil_data => filterdata_temp
		);  
  
	audio_inst : entity work.audio_interface
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
			ADCDATA => socadc
		);
	
	pll_inst: pll
		port map (
			refclk => CLOCK_50,
			rst => SW(9),
			outclk_0 => bitclk,  -- 1.536 MHz
			outclk_1 => clk, -- 49.152 MHz
			outclk_2 => adcclk, -- 49.152 MHz, was 24.576 MHz
			locked => rst);
			
			
			
--	Equalizer : entity work.Equalizermain -- equalizer Port/signal => main port/ignal
--	port map (
--        	main_CLK => clk,      
--        	Reset => rst,
--			dig0=>dig0,
--			dig1=>dig1,
--			dig2=>dig2 ,
--			dig3=>dig3 ,
--			dig4=>dig4 ,
--			dig5=>dig5,           
--        	new_val => sndclk,                
--        	data_in => mixed,                   
----		data_outbaseshelve => data_outbaseshelve_temp,
----		data_outmidpeak => data_outmidpeak_temp,
----		data_outtrebleshelve => data_outtrebleshelve_temp,
--		EQmain_out => EQ_out,
--		chanEQ => chan_temp,  
--		filteridEQ => filterid_temp,
--		filterdataEQ => filterdata_temp
--	);

SPIhandlerEqualizer : entity work.spi_slave_ui
	port map (
      clk => clk,	
		reset_n	 => rst,
		sclk => sclk,
		ss => ss,	
		mosi => mosi,	
		chan => chan_temp, 
		filterid => filterid_temp,
		filterdata => filterdata_temp, 
		--output => open,
		miso =>	miso
	);
			
	
				

end Behavioral;
