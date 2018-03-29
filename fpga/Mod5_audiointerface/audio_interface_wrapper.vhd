LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

ENTITY audio_interface_wrapper IS

end entity audio_interface_wrapper;

architecture behaviour of audio_interface_wrapper is

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
		AUD_ADCLRCK_GPIO_1: OUT std_logic;
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
signal data_adc : std_logic_vector(31 downto 0);
signal data_dac : std_logic_vector(15 downto 0);

begin
data_dac<= data_adc(31 downto 16);


Wrapper : audio_interface
port map (
		LDATA =>  data_dac,
		RDATA,
		clk, 
		Reset, 	   
		INIT_FINISH 		,
		adc_full 			,
		AUD_MCLK 			, -- Codec master clock OUTPUT
		MCLK_GPIO			,

		AUD_ADCLRCK,
		AUD_ADCLRCK_GPIO_1 ,
		AUD_ADCDAT 			,
		AUD_ADCDAT_GPIO_0	,
      AUD_BCLK 			,
		AUD_BCLK_GPIO_2	, 
		data_over 			,

      AUD_DACDAT 			,
		AUD_DACDAT_GPIO_4	,
		AUD_DACLRCK			,
		AUD_DACLRCK_GPIO_6,
		
		I2C_SDAT,
		I2C_SCLK ,		
		ADCDATA => data_adc
);



end architecture;

