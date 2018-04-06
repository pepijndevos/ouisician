library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity top is
GENERIC(
    d_width : INTEGER := 48
    ); --data bus width
PORT(
	clk	: IN std_logic; --50Mhz clock	
	
	--UI
	reset_n	: IN STD_LOGIC; --button
	dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	
	--FROM MASTER
	sclk	: IN STD_LOGIC;  --spi clk from master	
	ss	: IN STD_LOGIC;  --active low slave select
	mosi	: IN STD_LOGIC;  --master out, slave in
	--TO REST
	--receiveddata : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
	
	--TO MASTER
	
	miso	: out STD_LOGIC := 'Z'  --master in, slave out

	SIGNAL filter_ctrl_cha1  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha2  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha3  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha4  :  std_logic_vector(d_width-9 downto 0);
	
);
end;

architecture logic of top is
	SIGNAL output : std_logic_vector(d_width-1 DOWNTO 0);

  component spi_slave_ui
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
	--receiveddata : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
	
	--TO MASTER
	output : in std_logic_vector(d_width-1 DOWNTO 0);
	miso	: out STD_LOGIC := 'Z'  --master in, slave out

	SIGNAL filter_ctrl_cha1  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha2  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha3  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha4  :  std_logic_vector(d_width-9 downto 0);
	
    );
  end component;

  component filter_ctrl
	port (
	clk	: IN std_logic; --50Mhz clock	
	reset_n	: IN STD_LOGIC; --button
	dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	
	SIGNAL filter_ctrl_cha1  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha2  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha3  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha4  :  std_logic_vector(d_width-9 downto 0);
	);
    begin

  ui : spi_slave_ui port map (
    reset_n => reset_n,
    clk => clk,
    sclk => sclk,
    ss => ss,
    output => output,
    mosi => mosi,
	miso => miso,
	filter_ctrl_cha1=>filter_ctrl_cha1,
	filter_ctrl_cha2=>filter_ctrl_cha2,
	filter_ctrl_cha3=>filter_ctrl_cha3,
	filter_ctrl_cha4=>filter_ctrl_cha4,
  );
  
  filter : filter_ctrl port map (
    reset_n => reset_n,
    clk => clk,
	dig0=>dig0,
	dig1=>dig1,
	dig2=>dig2 ,
	dig3=>dig3 ,
	dig4=>dig4 ,
	dig5=>dig5, 
	filter_ctrl_cha1=>filter_ctrl_cha1,
	filter_ctrl_cha2=>filter_ctrl_cha2,
	filter_ctrl_cha3=>filter_ctrl_cha3,
	filter_ctrl_cha4=>filter_ctrl_cha4
  );
end;