LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 

ENTITY filter_ctrl IS
  PORT(
	clk	: IN std_logic; --50Mhz clock	
	reset_n	: IN STD_LOGIC; --button
	dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	
	SIGNAL filter_ctrl_cha1  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha2  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha3  :  std_logic_vector(d_width-9 downto 0);
	SIGNAL filter_ctrl_cha4  :  std_logic_vector(d_width-9 downto 0);
	
	);

END filter_ctrl;

ARCHITECTURE logic OF filter_ctrl IS
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
	COMPONENT low_pass
		
  	PORT(

		

		);

  	END COMPONENT low_pass;



	
BEGIN
	lp : low_pass
	PORT MAP (	

		); 

PROCESS(clk, reset_n)
	VARIABLE i : INTEGER := 0;
	
BEGIN
	IF reset_n = '0' THEN
		dig0 <= "0000000" ;
		dig1 <= "0000000" ;
		dig2 <= "0000000" ;
		dig3 <= "0000000" ;
		dig4 <= "0000000" ;
		dig5 <= "0000000" ;
	ELSIF rising_edge(clk) THEN
	
	dig0 <= hex2display(filter_ctrl_cha1(3 downto 0));
	dig1 <= hex2display(filter_ctrl_cha1(7 downto 4));
	dig2 <= hex2display(filter_ctrl_cha1(11 downto 8));
	dig3 <= hex2display(filter_ctrl_cha1(15 downto 12));
	dig4 <= hex2display(filter_ctrl_cha1(19 downto 16));
	dig5 <= hex2display(filter_ctrl_cha1(23 downto 20));

		
		
	


END PROCESS;

END logic;