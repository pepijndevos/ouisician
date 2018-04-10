LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 

ENTITY spi_slave_ui IS
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
	chan : inout STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterid : inout STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdata : inout STD_LOGIC_VECTOR(31 DOWNTO 0);
	--TO MASTER
	output : in std_logic_vector(d_width-1 DOWNTO 0);
	miso	: out STD_LOGIC := 'Z'  --master in, slave out
	
	);

END spi_slave_ui;

ARCHITECTURE logic OF spi_slave_ui IS
FUNCTION hex2display (n:std_logic_vector(3 DOWNTO 0)) RETURN std_logic_vector IS
    VARIABLE res : std_logic_vector(6 DOWNTO 0);
  BEGIN
    CASE n IS          --        gfedcba; low active
	    WHEN "0000" => RETURN NOT "0111111";
	    WHEN "0001" => RETURN NOT "0000110";
	    WHEN "0010" => RETURN NOT "1011011";
	    WHEN "0011" => RETURN NOT "1001111";
	    WHEN "0100" => RETURN NOT "1100110";
	    WHEN "0101" => RETURN NOT "1101101";
	    WHEN "0110" => RETURN NOT "1111101";
	    WHEN "0111" => RETURN NOT "0000111";
	    WHEN "1000" => RETURN NOT "1111111";
	    WHEN "1001" => RETURN NOT "1101111";
	    WHEN "1010" => RETURN NOT "1110111";
	    WHEN "1011" => RETURN NOT "1111100";
	    WHEN "1100" => RETURN NOT "0111001";
	    WHEN "1101" => RETURN NOT "1011110";
	    WHEN "1110" => RETURN NOT "1111001";
	    WHEN OTHERS => RETURN NOT "1110001";			
    END CASE;
  END hex2display;
	COMPONENT spi_slave
		
  	PORT(

		reset_n      : IN     STD_LOGIC;  --active low reset
		tx_load_en   : IN     STD_LOGIC;  --asynchronous transmit buffer load enable
		tx_load_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --asynchronous tx data to load
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
	
	--COMPONENT SPI_control
		-- PORT(
		--pins
		-- clk	: IN std_logic; --50Mhz clock	
		-- reset_n	: IN STD_LOGIC;
		-- ss : IN STD_LOGIC;
		-- dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
		--spi slave
		-- receiveddata : IN STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
		-- senddata : OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)

	   
	   -- );
	-- END COMPONENT;
 
	signal tx_load_data : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --asynchronous tx data to load
	signal rx_req       : STD_LOGIC;  --'1' while busy = '0' moves data to the rx_data output
    signal tx_load_en   : STD_LOGIC := '0';  --asynchronous transmit buffer load enable
   	signal trdy         : STD_LOGIC := '0';  --transmit ready bit
    signal rrdy         : STD_LOGIC := '0';  --receive ready bit
    signal roe          : STD_LOGIC := '0';  --receive overrun error bit
	SIGNAL rx_buf  	: STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0');  --receiver buffer
	SIGNAL rx_data	: STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0');  --receive register output to logic
	SIGNAL filterid_temp: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	
	--SIGNAL senddata : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
	

	
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

	-- s2: SPI_control
	-- PORT MAP (
			-- reset_n => reset_n,
			-- clk => clk,
			-- ss => ss,
			-- dig0=>dig0,
			-- dig1=>dig1,
			-- dig2=>dig2 ,
			-- dig3=>dig3 ,
			-- dig4=>dig4 ,
			-- dig5=>dig5, 
			-- receiveddata => rx_data,
			-- senddata => senddata
		-- );

PROCESS(clk, reset_n)
	VARIABLE i : INTEGER := 0;
	
BEGIN
	IF reset_n = '0' THEN
		tx_load_en <= '0';
		tx_load_data <= (OTHERS => '0');
		dig0 <= "0000000" ;
		dig1 <= "0000000" ;
		dig2 <= "0000000" ;
		dig3 <= "0000000" ;
		dig4 <= "0000000" ;
		dig5 <= "0000000" ;
	ELSIF rising_edge(clk) THEN

		--receiving part
		IF rrdy = '1' AND ss = '1' THEN
			rx_req <= '1';
			--receiveddata <= rx_data;

			chan <= rx_data(47 DOWNTO 40);
			filterid <= rx_data(39 DOWNTO 32);
			filterdata <= rx_data(31 DOWNTO 0);

			IF chan = "00000001" THEN
				
				dig0 <= hex2display(rx_data(3 downto 0));
				dig1 <= hex2display(rx_data(7 downto 4));
				dig2 <= hex2display(rx_data(11 downto 8));
				dig3 <= hex2display(rx_data(15 downto 12));
				--dig4 <= hex2display(rx_data(19 downto 16));
				dig5 <= hex2display(filterid(7 downto 4));
				dig4 <= hex2display(filterid(3 downto 0));
			ELSIF rx_data(47 DOWNTO 40) = "00000010" THEN
				
			ELSIF rx_data(47 DOWNTO 40) = "00000011" THEN
				
			ELSIF rx_data(47 DOWNTO 40) = "00000100" THEN
				
			END IF;
		ELSIF rx_req <= '1' AND ss = '0' THEN
			rx_req <= '0';
		END IF;
		
		
		
	
		
		--transmit part

		tx_load_data <= rx_data;--output;
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