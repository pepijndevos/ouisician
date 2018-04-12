LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   
--use ieee.std_logic_signed.all;

entity IIRDF1_BW is
generic (
   W_in : integer ;
	W_coef : integer; 
	A0 : integer;
	A2 : integer;
	B0 : integer ;
	B1 : integer;
	B2 : integer 
);
port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0);   -- Output
   A1 				 : in signed(W_coef-1 downto 0)
	

);
end entity IIRDF1_BW;

architecture behaviour of IIRDF1_BW is
constant W_register : integer := W_coef*2;
constant scale : integer := 2**(W_coef-W_in);
type STATE_TYPE is (idle,mul1,mul2,mul3,truncate,sum,done);
signal state : STATE_TYPE;

signal cA1 : signed(W_coef-1 downto 0);
constant cA2 : signed(W_coef-1 downto 0):=to_signed(A2,W_coef);
constant cB0 : signed(W_coef-1 downto 0):=to_signed(B0,W_coef);
constant cB1 : signed(W_coef-1 downto 0):=to_signed(B1,W_coef);
constant cB2 : signed(W_coef-1 downto 0):=to_signed(B2,W_coef);
constant cA0 : signed(W_coef-1 downto 0):=to_signed(A0,W_coef);


signal nZX1,nZX2,nZY1,nZY2 : signed(W_register-1 downto 0) := (others => '0');
signal nGB0,nGB1,nGB2,nGA1,nGA2 : signed(W_register+4 downto 0) := (others => '0');
signal accum : signed(W_register+4 downto 0) := (others => '0');
signal nYOUT : signed(W_register-1 downto 0) := (others => '0');
signal IIR_out_temp : signed(W_in-1 downto 0):=(others =>'0');


begin
cA1 <= A1;
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
			if(new_val ='1') then
				state<= mul1;
			end if;
		when mul1 =>
			nZX1<= resize(IIR_in*scale,nZX1'LENGTH);
			nZX2<= nZX1;
			nGB1<= resize(nZX1*cB1,nGB1'LENGTH);
			nGB2<= resize(nZX2*cB2,nGB2'LENGTH);
			nGA1<= resize(nZY1*cA1,nGA1'LENGTH);
			nGA2<= resize(nZY2*cA2,nGA2'LENGTH);
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