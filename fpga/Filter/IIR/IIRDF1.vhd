
-- IIR Filter after IIR Direct Form 1
-- Filter can be cascaded
-- B0-B2 and A1+A2 are the coefficients in Q2.X format
-- Scaling depends on chosen Q-Format, integer-width of fixed point is always 2
--


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;   
--use ieee.std_logic_signed.all;


entity IIRDF1 is
    generic (
        INPUT_WIDTH : integer := 32;
        QFORMAT   : integer := 30;  
      A0 : real := 1.0;
    	B0 : real := 0.9862119; 
    	B1 : real := -1.972423;
   	B2 : real := 0.9862119;
   	A1 : real := -1.972233;
    	A2 : real :=  0.9726139
    );
        
    port (
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        --sCLK            : in std_logic;                         -- indicates a new input value
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end entity IIRDF1;

architecture behaviour of IIRDF1 is

type STATE_TYPE is (idle,truncate, sum1,done);
signal state : STATE_TYPE;
constant cA1 : signed(QFORMAT+1 downto 0)  := to_signed(integer(A1*(2.0**QFORMAT)), QFORMAT+2);-- A1
constant cA2 : signed(QFORMAT+1 downto 0)  := to_signed(integer(A2*(2.0**QFORMAT)), QFORMAT+2);-- A2
constant cB0 : signed(QFORMAT+1 downto 0)  := to_signed(integer(B0*(2.0**QFORMAT)), QFORMAT+2);-- B1
constant cB1 : signed(QFORMAT+1 downto 0)  := to_signed(integer(B1*(2.0**QFORMAT)), QFORMAT+2);-- B1
constant cB2 : signed(QFORMAT+1 downto 0)  := to_signed(integer(B2*(2.0**QFORMAT)), QFORMAT+2);-- B1
constant cA0 : signed(QFORMAT+1 downto 0)  := to_signed(integer(A0*(2.0**QFORMAT)), QFORMAT+2);-- output scale

signal nZX0,nZX1,nZX2,nZY1,nZY2 : signed(INPUT_WIDTH+1 downto 0) := (others => '0');
signal nGB0,nGB1,nGB2,nGA1,nGA2 : signed(INPUT_WIDTH+1+QFORMAT+2 downto 0) := (others => '0');
signal nDX0,nDX1,nDX2,nDY1,nDY2 : signed(INPUT_WIDTH+1 downto 0) := (others => '0');
signal nYOUT : signed(INPUT_WIDTH+1 downto 0) := (others => '0');
signal new_val : std_logic := '0';

signal iIIR_RX         :  signed (INPUT_WIDTH-1 downto 0);
signal oIIR_TX         :  signed (INPUT_WIDTH-1 downto 0);   -- Output

--signal sCLKprev : std_logic := '0';
signal counter : integer := 0;

begin
iIIR_RX <= resize(IIR_in,32); -- cast input to 32
IIR_out <= resize(oIIR_TX,16);-- cast output to 16 bits

process(iCLK)
begin
if(rising_edge(iCLK)) then
	--if(sCLKprev = '0' and sCLK ='1') then
	if(counter = 1041) then 
		new_val <= '1';
		counter <= 0;
	else
		new_val <= '0';
		counter <= counter+1;
	end if;
--sCLKprev <= sCLK;
end if;
end process;


--process(iCLK,sCLK)
--begin
--if(rising_edge(iCLK)) then
--	if(rising_edge(sCLK)) then
--		new_val <= '1';
--	else
--	new_val <= '0';
--	end if;
--end if;
--end process;


process(iCLK,iRESET_N)
begin
    if(rising_edge(iCLK)) then
        if(iRESET_N = '0') then
            nZX0                <= (others => '0');
            nZX1                <= (others => '0');
            nZX2                <= (others => '0');
            nZY1                <= (others => '0');
            nZY2                <= (others => '0');
            nGB0                <= (others => '0');
            nGB1                <= (others => '0');
            nGB2                <= (others => '0');
            nGA1                <= (others => '0');
            nGA2                <= (others => '0');
            nDX0                <= (others => '0');
            nDX1                <= (others => '0');
            nDX2                <= (others => '0');
            nDY1                <= (others => '0');
            nDY2                <= (others => '0');
            nYOUT               <= (others => '0');
        else
            case state is 
                when idle =>
                    if(new_val = '1') then
                        nZX0        <= resize(iIIR_RX,nZX0'LENGTH);
                        nZX1        <= nZX0;
                        nZX2        <= nZX1;
                        nGB0        <= cB0 * nZX0;
                        nGB1        <= cB1 * nZX1;
                        nGB2        <= cB2 * nZX2;
                        nGA1        <= cA1 * nZY1;
                        nGA2        <= cA2 * nZY2;
                        state       <= truncate;
                    end if;
                   when truncate =>
                        nDX0        <= nGB0(nGB0'left-2 downto QFORMAT);
                        nDX1        <= nGB1(nGB1'left-2 downto QFORMAT);
                        nDX2        <= nGB2(nGB2'left-2 downto QFORMAT);
                        nDY1        <= nGA1(nGA1'left-2 downto QFORMAT);
                        nDY2        <= nGA2(nGA2'left-2 downto QFORMAT);
                        state       <= sum1;
                    when sum1 =>
                        nYOUT       <= nDX0+nDX1+nDX2-nDY1-nDY2;
                        state       <= done;
                   when done =>
								oIIR_TX     <= nYOUT(INPUT_WIDTH-1 downto 0);
                        nZY1        <= nYOUT;
                        nZY2        <= nZY1;
                        state       <= idle;
                when others =>
                    state           <= idle;
            end case;
        end if;
    end if;
end process;
end architecture;