LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   
--use ieee.std_logic_signed.all;


entity IIRDF1EQ is
generic (
    W_in : integer ;
	 W_coef : integer  
--    B0 : integer ; 
--    B1 : integer ;
--    B2 : integer ;
--    A0 : integer ;
--    A1 : integer ;
--    A2 : integer 
);
port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0);   -- Output
	chanFIL : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridFIL : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataFIL : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	A0port : in STD_LOGIC_VECTOR(23 DOWNTO 0); 
	A1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	coefficientFLAG : in STD_LOGIC
);
end entity IIRDF1EQ;

architecture behaviour of IIRDF1EQ is

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

constant W_register : integer := W_coef*2;
constant scale : integer := 2**(W_coef-W_in);
type STATE_TYPE is (idle,mul1,mul2,mul3,truncate,sum,done);
signal state : STATE_TYPE;

--constant cA1 : signed(W_coef-1 downto 0)  := to_signed(A1,W_coef);
--constant cA2 : signed(W_coef-1 downto 0)  := to_signed(A2,W_coef);
--constant cB0 : signed(W_coef-1 downto 0)  := to_signed(B0,W_coef);
--constant cB1 : signed(W_coef-1 downto 0)  := to_signed(B1,W_coef);
--constant cB2 : signed(W_coef-1 downto 0)  := to_signed(B2,W_coef);
--constant cA0 : signed(W_coef-1 downto 0)  := to_signed(A0,W_coef);

signal cA1 : signed(W_coef-1 downto 0);--  := to_signed(A1,W_coef);
signal cA2 : signed(W_coef-1 downto 0);--  := to_signed(A2,W_coef);
signal cB0 : signed(W_coef-1 downto 0);--  := to_signed(B0,W_coef);
signal cB1 : signed(W_coef-1 downto 0);--  := to_signed(B1,W_coef);
signal cB2 : signed(W_coef-1 downto 0);--  := to_signed(B2,W_coef);
signal cA0 : signed(W_coef-1 downto 0);--  := to_signed(A0,W_coef);

signal nZX1,nZX2,nZY1,nZY2 : signed(W_register-1 downto 0) := (others => '0');
signal nGB0,nGB1,nGB2,nGA1,nGA2 : signed(W_register+4 downto 0) := (others => '0');
signal accum : signed(W_register+4 downto 0) := (others => '0');
signal nYOUT : signed(W_register-1 downto 0) := (others => '0');
signal IIR_out_temp : signed(W_in-1 downto 0):=(others =>'0');
signal coefficientFLAG_temp, coefficientFLAG_temp_old : std_logic;
begin
					cA0 <= resize(signed(A0port),W_coef); 
					cA1 <= resize(signed(A1port),W_coef); 
					cA2 <= resize(signed(A2port),W_coef); 
					cB0 <= resize(signed(B0port),W_coef); 
					cB1 <= resize(signed(B1port),W_coef); 
					cB2 <= resize(signed(B2port),W_coef);

				dig0 <= hex2display(STD_LOGIC_VECTOR(cB0(3 downto 0)));
				dig1 <= hex2display(STD_LOGIC_VECTOR(cB0(7 downto 4)));
				dig2 <= hex2display(STD_LOGIC_VECTOR(cB0(11 downto 8)));
				dig3 <= hex2display(STD_LOGIC_VECTOR(cB0(15 downto 12)));
				dig4 <= hex2display(STD_LOGIC_VECTOR("000" & cB0(16 downto 16)));
				--dig4 <= hex2display(B0LOW_temp(23 downto 20));

process(iCLK,iRESET_N)
begin
if(iRESET_N = '0') then
	nZX1 <= (others => '0');
	nZX2 <= (others => '0');
	nZY1 <= (others => '0');
	nZY2 <= (others => '0');
	nYOUT <= (others => '0');
elsif(rising_edge(iCLK)) then
	IIR_out <= IIR_out_temp;
	case state is
		when idle =>
			if(new_val ='1') then -- RECALCULATE COEFFICIENTS
				-- FIXME: only do this when new coefficient values have been send
				--coefficientFLAG_temp <= coefficientFLAG;
				--if(coefficientFLAG_temp /= coefficientFLAG_temp_old) then

--					coefficientFLAG_temp_old <= coefficientFLAG_temp;  
				--end if;
				state<= mul1;
			end if;
		when mul1 =>
			nZX1<= resize(IIR_in*scale,nZX1'LENGTH);
			nZX2<= nZX1;
			nGB1<= resize(nZX1*cB1,nGB1'LENGTH);
			nGB2<= resize(nZX2*cB2,nGB2'LENGTH);
			state <= mul2;
		when mul2=>
			nGA1<= resize(nZY1*cA1,nGA1'LENGTH);
			nGA2<= resize(nZY2*cA2,nGA2'LENGTH);
			state<=mul3;
		when mul3 =>
         nGB0<= resize(cB0*IIR_in*scale,nGB0'LENGTH);
			state <= sum;
		when sum =>
			accum   <= resize(nGB0+nGB1+nGB2-nGA1-nGA2,accum'LENGTH);
			state <= truncate;
		when truncate =>
			nYOUT <= resize(accum/cA0,nZY1'LENGTH);
			state <= done;
		when done =>
			IIR_out_temp <= resize(nYOUT/scale,IIR_out'LENGTH);
			nZY2 <= nZY1;
			nZY1 <= nYOUT;
			state <= idle;
		when others =>
			state <= idle;
		end case;
end if;
end process;
end architecture;