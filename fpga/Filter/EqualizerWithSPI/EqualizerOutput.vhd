LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity EqualizerOutput is

    port (
		main_CLK       		: in std_logic;
		Reset          		: in std_logic;
		--dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
                      
		data_baseshelve     : in signed (15 downto 0);
		data_midpeak       	: in signed (15 downto 0);   
		data_trebleshelve   : in signed (15 downto 0);   
		EQout  				: out signed (15 downto 0)
    );
end entity EqualizerOutput;

architecture behaviour of EqualizerOutput is


-- FUNCTION hex2display (n:std_logic_vector(3 DOWNTO 0)) RETURN std_logic_vector IS
    -- VARIABLE res : std_logic_vector(6 DOWNTO 0);
  -- BEGIN
    -- CASE n IS          --        gfedcba; low active
	    -- WHEN "0000" => RETURN NOT "0111111";
	    -- WHEN "0001" => RETURN NOT "0000110";
	    -- WHEN "0010" => RETURN NOT "1011011";
	    -- WHEN "0011" => RETURN NOT "1001111";
	    -- WHEN "0100" => RETURN NOT "1100110";
	    -- WHEN "0101" => RETURN NOT "1101101";
	    -- WHEN "0110" => RETURN NOT "1111101";
	    -- WHEN "0111" => RETURN NOT "0000111";
	    -- WHEN "1000" => RETURN NOT "1111111";
	    -- WHEN "1001" => RETURN NOT "1101111";
	    -- WHEN "1010" => RETURN NOT "1110111";
	    -- WHEN "1011" => RETURN NOT "1111100";
	    -- WHEN "1100" => RETURN NOT "0111001";
	    -- WHEN "1101" => RETURN NOT "1011110";
	    -- WHEN "1110" => RETURN NOT "1111001";
	    -- WHEN OTHERS => RETURN NOT "1110001";			
    -- END CASE;
  -- END hex2display;
--signal EQout_temp : signed (15 downto 0) := (others => '0');
--signal EQout_temp_resize : signed (15 downto 0) := (others => '0');
begin
--EQout_temp <= data_baseshelve;
	process(main_CLK,Reset)
		begin
			if(Reset = '0') then
				EQout <= x"0000"; -- no output
				--EQout_temp <= x"0000";
			elsif(rising_edge(main_CLK)) then
				--EQout_temp <= (data_baseshelve+data_midpeak+data_trebleshelve)/3; -- use larger size to store addition?
				EQout <= shift_right(data_baseshelve+data_trebleshelve,1); -- Final equalized output
			end if;
		end process;
end architecture;


