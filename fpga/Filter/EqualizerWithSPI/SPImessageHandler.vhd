
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   
--use ieee.std_logic_signed.all;


entity SPImessageHandler is

port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	chanHandler : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridHandler : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataHandler : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	A0LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);

	A0MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);

	A0HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	
	flagLOW : out STD_LOGIC := '0';
	flagMID : out STD_LOGIC := '0';
	flagHigh : out STD_LOGIC := '0'
);
end entity SPImessageHandler;

architecture behaviour of SPImessageHandler is

signal A0HIGH_temp, A1HIGH_temp, A2HIGH_temp, B0HIGH_temp, B1HIGH_temp, B2HIGH_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal A0MID_temp, A1MID_temp, A2MID_temp, B0MID_temp, B1MID_temp, B2MID_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal A0LOW_temp, A1LOW_temp, A2LOW_temp, B0LOW_temp, B1LOW_temp, B2LOW_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal flagLOWtemp, flagMIDtemp, flagHightemp : STD_LOGIC := '0';
begin

SPImessageDecoder : process(iCLK,iRESET_N)
begin
if(iRESET_N = '0') then

A0LOW <= std_logic_vector(to_signed(4096,24));
A1LOW <= std_logic_vector(to_signed(0,24));
A2LOW <= std_logic_vector(to_signed(0,24));
B0LOW <= std_logic_vector(to_signed(4096,24));
B1LOW <= std_logic_vector(to_signed(0,24));
B2LOW <= std_logic_vector(to_signed(0,24));
         
A0MID <= std_logic_vector(to_signed(4096,24));
A1MID <= std_logic_vector(to_signed(-5929,24));
A2MID <= std_logic_vector(to_signed(3377,24));
B0MID <= std_logic_vector(to_signed(4096,24));
B1MID <= std_logic_vector(to_signed(-5929,24));				
B2MID <= std_logic_vector(to_signed(3377,24));
         
A0HIGH <=  std_logic_vector(to_signed(4096,24));
A1HIGH <= std_logic_vector(to_signed(0,24));
A2HIGH <= std_logic_vector(to_signed(0,24));
B0HIGH <= std_logic_vector(to_signed(4096,24));
B1HIGH <= std_logic_vector(to_signed(0,24));
B2HIGH <= std_logic_vector(to_signed(0,24));
elsif(rising_edge(iCLK)) then
case chanHandler(2 DOWNTO 0) is 
	when "001" | "010" | "011" | "100" =>-- we don't do channel distuingishing for now
		case filteridHandler(1 DOWNTO 0) is-- CHOOSE EQ TYPE (LOW,MID,HIGH)
			when "11" => -- HIGH
				case filterdataHandler(26 DOWNTO 24) is-- CHECK WHICH COEFFICIENT IT IS
					when "000" =>-- A0
						A0HIGH_temp <= filterdataHandler(23 DOWNTO 0);
					when "001" =>-- A1
						A1HIGH_temp <= filterdataHandler(23 DOWNTO 0);
					when "010" =>-- A2
						A2HIGH_temp <= filterdataHandler(23 DOWNTO 0);
					when "011" =>-- B0
						B0HIGH_temp <= filterdataHandler(23 DOWNTO 0);
					when "100" =>-- B1
						B1HIGH_temp <= filterdataHandler(23 DOWNTO 0);
					when "101" =>-- B2
						-- Send coefficients in one burst
						A0HIGH <= A0HIGH_temp;
						A1HIGH <= A1HIGH_temp;
						A2HIGH <= A2HIGH_temp;
						B0HIGH <= B0HIGH_temp;
						B1HIGH <= B1HIGH_temp;						
						B2HIGH <= filterdataHandler(23 DOWNTO 0);
						flagHIGHtemp <= not flagHIGHtemp;
						flagHIGH <= flagHIGHtemp;
					when others => 
						null;
				end case;
			when "10" => -- MID
				case filterdataHandler(26 DOWNTO 24) is
					when "000" =>-- A0
						A0MID_temp <= filterdataHandler(23 DOWNTO 0);
					when "001" =>-- A1
						A1MID_temp <= filterdataHandler(23 DOWNTO 0);
					when "010" =>-- A2
						A2MID_temp <= filterdataHandler(23 DOWNTO 0);
					when "011" =>-- B0
						B0MID_temp <= filterdataHandler(23 DOWNTO 0);
					when "100" =>-- B1
						B1MID_temp <= filterdataHandler(23 DOWNTO 0);
					when "101" =>-- B2
						-- Send coefficients in one burst
						A0MID <= A0MID_temp;
						A1MID <= A1MID_temp;
						A2MID <= A2MID_temp;
						B0MID <= B0MID_temp;
						B1MID <= B1MID_temp;						
						B2MID <= filterdataHandler(23 DOWNTO 0);
						flagMIDtemp <= not flagMIDtemp;
						flagMID <= flagMIDtemp;
					when others => 
						null;
				end case;
			when "01" => -- LOW
				case filterdataHandler(26 DOWNTO 24) is
					when "000" =>-- A0
						A0LOW_temp <= filterdataHandler(23 DOWNTO 0);
					when "001" =>-- A1
						A1LOW_temp <= filterdataHandler(23 DOWNTO 0);
					when "010" =>-- A2
						A2LOW_temp <= filterdataHandler(23 DOWNTO 0);
					when "011" =>-- B0
						B0LOW_temp <= filterdataHandler(23 DOWNTO 0);
					when "100" =>-- B1
						B1LOW_temp <= filterdataHandler(23 DOWNTO 0);
					when "101" =>-- B2
						-- Send coefficients in one burst
						A0LOW <= A0LOW_temp;
						A1LOW <= A1LOW_temp;
						A2LOW <= A2LOW_temp;
						B0LOW <= B0LOW_temp;
						B1LOW <= B1LOW_temp;		
						B2LOW <= filterdataHandler(23 DOWNTO 0);
						flagLOWtemp <= not flagLOWtemp;
						flagLOW <= flagLOWtemp;
					when others => 
						null;
				end case;
			when others =>
				null;
		end case;
	when others =>
		null;
end case;
end if;
end process;


end architecture;