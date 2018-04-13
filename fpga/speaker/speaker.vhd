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
		 
		 
		HEX0	: OUT std_logic_vector(6 DOWNTO 0); 
		HEX1	: OUT std_logic_vector(6 DOWNTO 0); 
		HEX2	: OUT std_logic_vector(6 DOWNTO 0); 
		HEX3	: OUT std_logic_vector(6 DOWNTO 0); 
		HEX4	: OUT std_logic_vector(6 DOWNTO 0); 
		HEX5 	: OUT std_logic_vector(6 DOWNTO 0);
		
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
  signal halfclk : std_logic;
  signal clk : std_logic;

  signal Trem_out1 : signed(15 downto 0);
  signal Trem_out2 : signed(15 downto 0);
  signal delay_out1 : signed(15 downto 0);
  signal delay_out2 : signed(15 downto 0);
  signal offset : unsigned(15 downto 0);
  
   signal	max_ampl :  unsigned(15 downto 0);
	signal	speed :  unsigned(15 downto 0);
   signal   bl_gain1 :  integer range 0 to 256;
   signal   ff_gain11 :  integer range 0 to 256;
   signal   fb_gain11 :  integer range 0 to 256;
   signal   ff_gain21 :  integer range 0 to 256;
   signal   fb_gain21 :  integer range 0 to 256;
   signal   ff_gain31 :  integer range 0 to 256;
   signal   fb_gain31 :  integer range 0 to 256;
   signal   offset11  :  unsigned(19 downto 0);
   signal   offset21  :  unsigned(19 downto 0);
   signal   offset31  :  unsigned(19 downto 0);
	signal   bl_gain2 :  integer range 0 to 256;
   signal   ff_gain12 :  integer range 0 to 256;
   signal   fb_gain12 :  integer range 0 to 256;
   signal   ff_gain22 :  integer range 0 to 256;
   signal   fb_gain22 :  integer range 0 to 256;
   signal   ff_gain32 :  integer range 0 to 256;
   signal   fb_gain32:  integer range 0 to 256;
   signal   offset12  :  unsigned(19 downto 0);
   signal   offset22  :  unsigned(19 downto 0);
	signal 	offset32 : unsigned(19 downto 0);
  
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
GPIO_ADCCLK1 <= clk;
GPIO_ADCCLK2 <= clk;

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
	data_out => Trem_out1,
	CLK_50 => clk,
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
      data_in => Trem_out1,
      data_outlow => wout1,
		data_outhigh => wout2
		);
		
 comb_inst1 : entity work.comb
	port map (
	  rst => rst,
    clk => clk,
    sndclk => sndclk,
    bl_gain => bl_gain1,
    ff_gain1 => ff_gain11,
    fb_gain1 => fb_gain11,
    ff_gain2 => ff_gain21,
    fb_gain2 => fb_gain21,
    ff_gain3 => ff_gain31,
    fb_gain3 => fb_gain31,
    offset1 => resize(offset+offset11, 20),
    offset2 => resize(offset+offset21, 20),
    offset3 => resize(offset+offset31, 20),
    word => win1,
    resp => delay_out1
  );
  
 delayhandler_inst1 : entity work.delayhandler
	generic map (
		mychan => x"01",
		base_addr => 6
	)
	port map (
	 rst => rst,
    clk => clk,
	 chan => chan_temp,  
	 filterid => filterid_temp,
	 filterdata => filterdata_temp,
	 max_ampl => max_ampl,
	 speed => speed,
    bl_gain => bl_gain1,
    ff_gain1 => ff_gain11,
    fb_gain1 => fb_gain11,
    ff_gain2 => ff_gain21,
    fb_gain2 => fb_gain21,
    ff_gain3 => ff_gain31,
    fb_gain3 => fb_gain31,
    offset1 => offset11,
    offset2 => offset21,
    offset3 => offset31
  );

   comb_inst2 : entity work.comb
	port map (
	  rst => rst,
    clk => clk,
    sndclk => sndclk,
    bl_gain => bl_gain2,
    ff_gain1 => ff_gain12,
    fb_gain1 => fb_gain12,
    ff_gain2 => ff_gain22,
    fb_gain2 => fb_gain22,
    ff_gain3 => ff_gain32,
    fb_gain3 => fb_gain32,
    offset1 => resize(offset+offset12, 20),
    offset2 => resize(offset+offset22, 20),
    offset3 => resize(offset+offset32, 20),
    word => win2,
    resp => delay_out2
  );
  
 delayhandler_inst2 : entity work.delayhandler
	generic map (
		mychan => x"02",
		base_addr => 6
	)
	port map (
	 rst => rst,
    clk => clk,
	 chan => chan_temp,  
	 filterid => filterid_temp,
	 filterdata => filterdata_temp,
	 max_ampl => open,
	 speed => open,
    bl_gain => bl_gain2,
    ff_gain1 => ff_gain12,
    fb_gain1 => fb_gain12,
    ff_gain2 => ff_gain22,
    fb_gain2 => fb_gain22,
    ff_gain3 => ff_gain32,
    fb_gain3 => fb_gain32,
    offset1 => offset12,
    offset2 => offset22,
    offset3 => offset32
);

  triangle_inst : entity work.triangle
  port map (
    max_ampl => max_ampl,
	 speed => speed,
    rst => rst,
    clk => clk,
    data => offset
);


  mixer_inst: entity work.mixer
    port map (rst => rst,
      clk => sndclk,
      word1 => delay_out1,
      word2 => delay_out2,
      word3 => pi1,
      word4 => pi2,
      resp => mixed);
		
		
  i2s_inst: entity work.i2s
    port map (rst => rst,
      bclk => bitclk,
      rlclk => GPIO_LRCK,
      din => GPIO_DIN,
      dout => GPIO_DOUT,
      win1 => mixed,
      win2 => mixed,
      wout1 => pi1,
      wout2 => pi2);

  adc_inst1: entity work.adc(behavioral)
    generic map (
      use_fir => false
    )
    port map (rst => rst,
      clk => clk,
		sndclk => sndclk2,
      data => GPIO_ADCDAT1,
      word => myadc1);
		
  adc_inst2: entity work.adc(behavioral)
    generic map (
      use_fir => false
	 )
    port map (rst => rst,
      clk => clk,
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
			outclk_2 => halfclk, -- 24.576 MHz
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
