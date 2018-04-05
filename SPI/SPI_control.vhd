LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 

ENTITY SPI_control IS
  GENERIC(
    d_width : INTEGER := 24 --data bus width
);
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
	
END SPI_control;

ARCHITECTURE bhv OF SPI_control IS
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
  
SIGNAL senddata_temp : STD_LOGIC_VECTOR(d_width+8-1 DOWNTO 0);
SIGNAL datavailable : STD_LOGIC;


BEGIN


PROCESS(clk, reset_n)

BEGIN

IF reset_n = '0' THEN
	senddata <= (others => '0');
	senddata_temp <= (others => '0');
	
	dig0 <= "0000000" ;
		   dig1 <= "0000000" ;
		   dig2 <= "0000000" ;
		   dig3 <= "0000000" ;
		   dig4 <= "0000000" ;
		   dig5 <= "0000000" ;
		   
	
ELSIF rising_edge(clk) THEN

	dig0 <= hex2display(receiveddata(3 downto 0));
	dig1 <= hex2display(receiveddata(7 downto 4));
	dig2 <= hex2display(receiveddata(11 downto 8));
	dig3 <= hex2display(receiveddata(15 downto 12));
	dig4 <= hex2display(receiveddata(19 downto 16));
	dig5 <= hex2display(receiveddata(23 downto 20));

	senddata <= "00000000" & receiveddata;
END IF;
END PROCESS;

END bhv;
