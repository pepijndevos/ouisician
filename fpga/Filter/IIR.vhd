LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   

entity IIR is
Generic (
    w_in : integer := 16;
    QFORMAT: integer:= 30; --Q2.30 format
    

    B0 : real := 0.00009506; 
    B1 : real := 0.00019012;
    B2 : real := 0.00009506;
    A1 : real := -1.97223373;
    A2 : real := 0.972613969;
    A0 : real := 1.0
);
Port ( iCLK : in STD_LOGIC;
	    sCLK : in STD_LOGIC;
       Reset : in STD_LOGIC;
       IIR_in : in SIGNED(w_in-1 downto 0);
       IIR_out : out SIGNED(w_in-1 downto 0)
);
end IIR;

architecture behaviour of IIR is

type STATE_TYPE is (idle, sum);
signal state : STATE_TYPE;
constant cA1 : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(A1*(2.0**QFORMAT)), QFORMAT+2); --Q_format is Q2.30
constant cA2 : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(A2*(2.0**QFORMAT)), QFORMAT+2);
constant cB0 : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(B0*(2.0**QFORMAT)), QFORMAT+2);
constant cB1 : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(B1*(2.0**QFORMAT)), QFORMAT+2);
constant cB2 : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(B2*(2.0**QFORMAT)), QFORMAT+2);
constant cScale : signed(QFORMAT+2-1 downto 0)  := to_signed(integer(A0*(2.0**QFORMAT)), QFORMAT+2); -- output scale

signal ZX0,ZX1,ZX2 : signed(w_in-1+4 downto 0) := (others => '0'); --pre gain
signal ZY1,ZY2 :signed(w_in-1+2+4 downto 0) := (others => '0'); --post gain
signal nB0,nB1,nB2,nA1,nA2 : signed (w_in-1+2+4 downto 0) := (others=>'0'); --2 bit from Qformat, post gain


begin
state_machine: process(iCLK,Reset)
begin
   if(rising_edge(iCLK)) then
		if(Reset = '0') then
			ZX0 <= (others => '0');
			ZX1 <= (others => '0');
			ZX2 <= (others => '0');
			ZY1 <= (others => '0');
			ZY2 <= (others => '0');
			nB0 <= (others => '0');
			nB1 <= (others => '0');
			nB2 <= (others => '0');
			nA1 <= (others => '0');
			nA2 <= (others => '0');
	else
	case state is
			when idle =>
				if (rising_edge(sCLK)) then
					ZX0 <= resize(IIR_in,ZX0'LENGTH);
					ZX1 <= ZX0;
					ZX2 <= ZX1;
					nB0 <= resize(shift_right(cB0*ZX0,QFORMAT),nB0'Length);
					nB1 <= resize(shift_right(cB1*ZX1,QFORMAT),nB1'Length);
					nB2 <= resize(shift_right(cB2*ZX2,QFORMAT),nB2'Length);
					nA1 <= resize(shift_right(cB0*ZX0,QFORMAT),nA1'Length);
					nA2 <= resize(shift_right(cB0*ZX0,QFORMAT),nA2'Length);
					IIR_out <= resize(shift_right(ZY1*cScale,QFORMAT),w_in);
					state<= sum;
				end if;
			when sum =>
					ZY1 <= nB0+nB1+nB2-nA1-nA2;
					ZY2 <= ZY1;
					state <= idle;
			when others =>
				state <= idle;
		end case;
	end if;
end if;
end process;
end behaviour;


