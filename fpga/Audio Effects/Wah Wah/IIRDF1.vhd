LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   
--use ieee.std_logic_signed.all;

entity IIRDF1 is
generic (
    W_in : integer ;
	 W_coef : integer   
);
port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0);   -- Output

	B0 : in signed(W_coef-1 downto 0);  
   B1 : in signed(W_coef-1 downto 0);
   B2 : in signed(W_coef-1 downto 0);
   A0 : in signed(W_coef-1 downto 0);
   A1 : in signed(W_coef-1 downto 0);
   A2 : in signed(W_coef-1 downto 0)
);
end entity IIRDF1;

architecture behaviour of IIRDF1 is
constant W_register : integer := W_coef*2;
constant scale : integer := 2**(W_coef-W_in);
type STATE_TYPE is (idle,mul1,mul2,mul3,truncate,sum,done);
signal state : STATE_TYPE;

signal cA1 : signed(W_coef-1 downto 0);
signal cA2 : signed(W_coef-1 downto 0);
signal cB0 : signed(W_coef-1 downto 0);
signal cB1 : signed(W_coef-1 downto 0);
signal cB2 : signed(W_coef-1 downto 0);
signal cA0 : signed(W_coef-1 downto 0);


signal nZX1,nZX2,nZY1,nZY2 : signed(W_register-1 downto 0) := (others => '0');
signal nGB0,nGB1,nGB2,nGA1,nGA2 : signed(W_register+4 downto 0) := (others => '0');
signal accum : signed(W_register+4 downto 0) := (others => '0');
signal nYOUT : signed(W_register-1 downto 0) := (others => '0');
signal IIR_out_temp : signed(W_in-1 downto 0):=(others =>'0');


begin

process(iCLK,iRESET_N) --constants register handling
begin
if (iRESET_N = '0') then
	cA1 <= to_signed(-509973,W_coef);
	cA2 <= to_signed(248765,W_coef);
	cB0 <= to_signed(6689,W_coef);
	cB1 <= to_signed(0,W_coef);
	cB2 <= to_signed(-6689,W_coef);
	cA0 <= to_signed(262144,W_coef);
elsif (rising_edge(iCLK)) then
	if(new_val='1') then -- assuming always changing coefficient every new value.
		cA1 <= A1;
		cA2 <= A2;
		cB0 <= B0;
		cB1 <= B1;
		cB2 <= B2;
		cA0 <= A0; 
	end if;
end if;
end process;



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