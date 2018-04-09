LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

ENTITY main IS
	PORT
	(	
		clk				: In std_logic;
		Reset 	      : IN std_logic;
		--new_val 	: IN std_logic;
		--data_in         : in signed (15 downto 0);  
--		data_outbaseshelve : out signed (15 downto 0); -- NOT NECESSARY FOR NOW
--		data_outmidpeak : out signed (15 downto 0);
--		data_outtrebleshelve : out signed (15 downto 0); 
	
		AUD_MCLK 			: OUT std_logic; -- Codec master clock OUTPUT
		MCLK_GPIO			: OUT std_logic;

		AUD_ADCLRCK 		: IN std_logic; -- ADC data left/right select
		AUD_ADCLRCK_GPIO_1 : OUT std_logic;
		AUD_ADCDAT 			: IN std_logic;
		AUD_ADCDAT_GPIO_0	: out std_logic;
      		AUD_BCLK 			: IN std_logic; -- Digital Audio bit clock
		AUD_BCLK_GPIO_2	: OUT std_logic; 
		
      		AUD_DACDAT 			: OUT std_logic; -- DAC data line
		AUD_DACDAT_GPIO_4	: OUT std_logic;
		AUD_DACLRCK			: IN std_logic; -- DAC data left/right select
		AUD_DACLRCK_GPIO_6: OUT std_logic; 
		I2C_SDAT 			: OUT std_logic; -- serial interface data line
		I2C_SCLK 			: OUT std_logic;  -- serial interface clock	
		dig0	: OUT std_logic_vector(6 DOWNTO 0); 
		dig1	: OUT std_logic_vector(6 DOWNTO 0); 
		dig2	: OUT std_logic_vector(6 DOWNTO 0); 
		dig3	: OUT std_logic_vector(6 DOWNTO 0); 
		dig4	: OUT std_logic_vector(6 DOWNTO 0); 
		dig5 	: OUT std_logic_vector(6 DOWNTO 0); 
		--FROM MASTER
		sclk	: IN STD_LOGIC;  --spi clk from master	
		ss	: IN STD_LOGIC;  --active low slave select
		mosi	: IN STD_LOGIC;  --master out, slave in
		--TO MASTER
		miso	: out STD_LOGIC := 'Z'  --master in, slave out
	);
END main;

architecture behaviour of main is

component audio_interface is
	PORT
	(	
		LDATA, RDATA		: IN std_logic_vector(15 downto 0); -- parallel external data inputs
		clk, Reset 	      : IN std_logic; 
		INIT_FINISH 		: OUT std_logic;
		adc_full 			: OUT std_logic;
		AUD_MCLK 			: OUT std_logic; -- Codec master clock OUTPUT
		MCLK_GPIO			: OUT std_logic;

		AUD_ADCLRCK 		: IN std_logic; -- ADC data left/right select
		AUD_ADCLRCK_GPIO_1 : OUT std_logic;
		AUD_ADCDAT 			: IN std_logic;
		AUD_ADCDAT_GPIO_0	: out std_logic;
      		AUD_BCLK 			: IN std_logic; -- Digital Audio bit clock
		AUD_BCLK_GPIO_2	: OUT std_logic; 
		data_over 			: OUT std_logic; -- sample sync pulse

      		AUD_DACDAT 			: OUT std_logic; -- DAC data line
		AUD_DACDAT_GPIO_4	: OUT std_logic;
		AUD_DACLRCK			: IN std_logic; -- DAC data left/right select
		AUD_DACLRCK_GPIO_6: OUT std_logic; 
		
		I2C_SDAT 			: OUT std_logic; -- serial interface data line
		I2C_SCLK 			: OUT std_logic;  -- serial interface clock
		ADCDATA 				: OUT std_logic_vector(31 downto 0)
	);
end component;

component Equalizermain is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_outbaseshelve        : out signed (15 downto 0);   -- Output
	data_outmidpeak       : out signed (15 downto 0);   -- Output
	data_outtrebleshelve       : out signed (15 downto 0);   -- Output
	
	chanEQ : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridEQ : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataEQ : in STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end component;

component spi_slave_ui is
    port (
        clk	: IN std_logic; --50Mhz clock	
	--UI
	reset_n	: IN STD_LOGIC; --button
	dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	--FROM MASTER
	sclk	: IN STD_LOGIC;  --spi clk from master	
	ss	: IN STD_LOGIC;  --active low slave select
	mosi	: IN STD_LOGIC;  --master out, slave in
	--TO REST
	chan : out STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterid : out STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdata : out STD_LOGIC_VECTOR(31 DOWNTO 0);
	--TO MASTER
	miso	: out STD_LOGIC := 'Z'  --master in, slave out
	
	
    );
end component;

	--Connecting wires
	signal ADCDATA : std_logic_vector(31 downto 0) := (others=>'0');
	--signal data_in : signed(15 downto 0):= (others=>'0');
	signal data_outbaseshelve_temp : signed(15 downto 0):= (others=>'0');
	signal data_outmidpeak_temp : signed(15 downto 0):= (others=>'0');
	signal data_outtrebleshelve_temp : signed(15 downto 0):= (others=>'0');
	signal data_over_temp : std_logic := '0';
	signal data_in_temp : signed(15 downto 0):= (others=>'0');
	signal LDATA : std_logic_vector(15 downto 0);
	signal RDATA : std_logic_vector(15 downto 0);
	signal chan_temp :  STD_LOGIC_VECTOR(7 DOWNTO 0); 
	signal filterid_temp :  STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal filterdata_temp :  STD_LOGIC_VECTOR(31 DOWNTO 0); 
	
begin
--data_over <= data_over_temp;
--data_outbaseshelve <= data_outbaseshelve_temp;
--data_outmidpeak <= data_outmidpeak_temp;
--data_outtrebleshelve <= data_outtrebleshelve_temp;

data_in_temp <= signed(ADCDATA(31 downto 16));
LDATA <= std_logic_vector(data_outbaseshelve_temp); -- example
RDATA <= std_logic_vector(data_outtrebleshelve_temp); --example

--data_outmidpeak <= data_outmidpeak;
Equalizer : Equalizermain -- equalizer Port/signal => main port/ignal
	port map (
        	main_CLK => clk,      
        	Reset => Reset,          
        	new_val => data_over_temp,                
        	data_in => data_in_temp,                   
		data_outbaseshelve => data_outbaseshelve_temp,
		data_outmidpeak => data_outmidpeak_temp,
		data_outtrebleshelve => data_outtrebleshelve_temp,
		chanEQ => chan_temp,  
		filteridEQ => filterid_temp,
		filterdataEQ => filterdata_temp
	);

SPIhandlerEqualizer : spi_slave_ui
	port map (
        	clk => clk,	
		reset_n	 => Reset,
		dig0 => dig0,
		dig1 => dig1,
		dig2 => dig2,
		dig3 => dig3,
		dig4 => dig4,
		dig5 => dig5,
		sclk => sclk,
		ss => ss,	
		mosi => mosi,	
		chan => chan_temp, 
		filterid => filterid_temp,
		filterdata => filterdata_temp, 
		miso =>	miso
	);
	
Audio_chip : audio_interface
	port map(
		LDATA => LDATA,
	    	RDATA =>RDATA, --mono
		clk => clk,
		Reset =>	 Reset,   
		INIT_FINISH => open, 		
		adc_full => open,			
		AUD_MCLK =>AUD_MCLK,		
		MCLK_GPIO => MCLK_GPIO,

		AUD_ADCLRCK =>	AUD_ADCLRCK,
		AUD_ADCLRCK_GPIO_1 => AUD_ADCLRCK_GPIO_1,
		AUD_ADCDAT 	=>	AUD_ADCDAT,	
		AUD_ADCDAT_GPIO_0 =>	AUD_ADCDAT_GPIO_0,
      		AUD_BCLK =>	AUD_BCLK,
		AUD_BCLK_GPIO_2	=> AUD_BCLK_GPIO_2,
		data_over 	=>	data_over_temp,

      		AUD_DACDAT 	=>	AUD_DACDAT,
		AUD_DACDAT_GPIO_4	=> AUD_DACDAT_GPIO_4,
		AUD_DACLRCK			=> AUD_DACLRCK,
		AUD_DACLRCK_GPIO_6 =>AUD_DACLRCK_GPIO_6,
		
		I2C_SDAT => I2C_SDAT,		
		I2C_SCLK =>	I2C_SCLK,
		ADCDATA 	=> ADCDATA
	);
end behaviour;


