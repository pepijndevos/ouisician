LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 

ENTITY spi_slave_ui IS
GENERIC(
    d_width : INTEGER := 128
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

	--TO MASTER
	miso	: OUT    STD_LOGIC := 'Z' --master in, slave out
	
	);

END spi_slave_ui;

ARCHITECTURE logic OF spi_slave_ui IS

	COMPONENT spi_slave
		
  	PORT(

		reset_n      : IN     STD_LOGIC;  --active low reset
		tx_load_en   : IN     STD_LOGIC;  --asynchronous transmit buffer load enable
		tx_load_data : IN     STD_LOGIC_VECTOR(d_width+8-1 DOWNTO 0);  --asynchronous tx data to load
		rx_req       : IN     STD_LOGIC;  --'1' while busy = '0' moves data to the rx_data output

   		sclk         : IN     STD_LOGIC;  --spi clk from master	
    	ss         : IN     STD_LOGIC;  --active low slave select
    	mosi         : IN     STD_LOGIC;  --master out, slave in
    	trdy         : BUFFER STD_LOGIC := '0';  --transmit ready bit
    	rrdy         : BUFFER STD_LOGIC := '0';  --receive ready bit
    	roe          : BUFFER STD_LOGIC := '0';  --receive overrun error bit
    	rx_data      : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --receive register output to logic
    	miso         : OUT    STD_LOGIC := 'Z'; --master in, slave out
		rx_buf  	: BUFFER  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0')  --receiver buffer
	
		);

  	END COMPONENT spi_slave;
	
	COMPONENT SPI_control
		PORT(
		--pins
		clk	: IN std_logic; --50Mhz clock	
		reset_n	: IN STD_LOGIC;
		ss : IN STD_LOGIC;
		dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
		--spi slave
		receiveddata : IN STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
		senddata : OUT STD_LOGIC_VECTOR(d_width+8-1 DOWNTO 0)

	   
	   );
	END COMPONENT;
 
	signal tx_load_data : STD_LOGIC_VECTOR(d_width+8-1 DOWNTO 0);  --asynchronous tx data to load
	signal rx_req       : STD_LOGIC;  --'1' while busy = '0' moves data to the rx_data output
    signal tx_load_en   : STD_LOGIC := '0';  --asynchronous transmit buffer load enable
   	signal trdy         : STD_LOGIC := '0';  --transmit ready bit
    signal rrdy         : STD_LOGIC := '0';  --receive ready bit
    signal roe          : STD_LOGIC := '0';  --receive overrun error bit
	SIGNAL rx_buf  	: STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0');  --receiver buffer
	SIGNAL rx_data	: STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0');  --receive register output to logic


	SIGNAL senddata : STD_LOGIC_VECTOR(d_width+8-1 DOWNTO 0);
	

	
BEGIN
	sl : spi_slave
	PORT MAP (	
			reset_n => reset_n,
			tx_load_en => tx_load_en,
			tx_load_data => tx_load_data,
			rx_req => rx_req,
			sclk => sclk,
			ss => ss,
			mosi => mosi,
			rrdy => rrdy,
			trdy => trdy,
			rx_data => rx_data,
			miso => miso
		); 

	s2: SPI_control
	PORT MAP (
			reset_n => reset_n,
			clk => clk,
			ss => ss,
			dig0=>dig0,
			dig1=>dig1,
			dig2=>dig2 ,
			dig3=>dig3 ,
			dig4=>dig4 ,
			dig5=>dig5, 
			receiveddata => rx_data,
			senddata => senddata
		);

PROCESS(clk, reset_n)
	VARIABLE i : INTEGER := 0;
BEGIN
	IF reset_n = '0' THEN
		tx_load_en <= '0';
		tx_load_data <= (OTHERS => '0');
	ELSIF rising_edge(clk) THEN

		--receiving part
		IF rrdy = '1' AND ss = '1' THEN
			rx_req <= '1';
		ELSIF rx_req <= '1' AND ss = '0' THEN
			rx_req <= '0';
		END IF;

		--transmit part
		tx_load_data <= senddata;
		IF ss='1' THEN
			i := i+1;
			if i=10 then
				tx_load_en <= '1';
				i := 0;
			end if;
		ELSIF tx_load_en = '1' THEN
			tx_load_en <= '0';
		END IF;


	END IF;
END PROCESS;

END logic;