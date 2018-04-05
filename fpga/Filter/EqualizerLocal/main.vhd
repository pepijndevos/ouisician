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
		I2C_SCLK 			: OUT std_logic  -- serial interface clock	
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
	data_outtrebleshelve       : out signed (15 downto 0)   -- Output
	
    );
end component;

--Connecting wires
signal ADCDATA : std_logic_vector(31 downto 0) := (others=>'0');
--signal data_in : signed(15 downto 0):= (others=>'0');
signal data_outbaseshelve_temp: signed(15 downto 0):= (others=>'0');
signal data_outmidpeak_temp: signed(15 downto 0):= (others=>'0');
signal data_outtrebleshelve_temp: signed(15 downto 0):= (others=>'0');
signal data_over_temp: std_logic := '0';
signal data_in_temp: signed(15 downto 0):= (others=>'0');
signal LDATA : std_logic_vector(15 downto 0);
signal RDATA : std_logic_vector(15 downto 0);

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
		data_outtrebleshelve => data_outtrebleshelve_temp 
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


