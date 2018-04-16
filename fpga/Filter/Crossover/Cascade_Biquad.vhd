LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Cascade_Biquad is
Generic(
    W_in : integer ;
	 W_coef : integer;   
    B0 : integer ; 
    B1 : integer ;
    B2 : integer ;
    A0 : integer ;
    A1 : integer ;
    A2 : integer 
);
port (
	main_CLK       : in std_logic;
	Reset          : in std_logic;
	new_val       : in std_logic;                         -- indicates a new input value
	data_in         : in signed (15 downto 0);               
	data_out        : out signed (15 downto 0)   -- Output
);
end entity Cascade_Biquad;

architecture behaviour of Cascade_Biquad is

--Component initiate
component IIRDF1 is
generic (
    W_in : integer ;
	 W_coef : integer;   
    B0 : integer ; 
    B1 : integer ;
    B2 : integer ;
    A0 : integer ;
    A1 : integer ;
    A2 : integer 
);
port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	new_val         : in std_logic;       -- indicates a new input value, input from data_over
	IIR_in          : in signed (15 downto 0);   -- singed is expected             
	IIR_out         : out signed (15 downto 0)   -- Output
);
end component;

--Connection signals
signal signal_in : signed(15 downto 0) := (others=>'0');
signal IIR_connect : signed(15 downto 0) := (others=>'0');
signal signal_out : signed(15 downto 0) := x"0000";

begin
signal_in <= data_in;
data_out <=  signal_out;

IIR1_DF1 : IIRDF1
Generic map(
    W_in =>W_in,
	 W_coef => W_coef,
    B0  =>B0,
    B1  =>B1,
    B2  =>B2,
    A0  =>A0,
    A1  =>A1,
    A2  =>A2
)
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	new_val    => new_val ,
	IIR_in     => signal_in,
	IIR_out     => IIR_connect
);

IIR2_DF1 : IIRDF1
Generic map(
    W_in =>W_in,
	 W_coef => W_coef,
    B0  =>B0,
    B1  =>B1,
    B2  =>B2,
    A0  =>A0,
    A1  =>A1,
    A2  =>A2
)
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	new_val    => new_val  ,
	IIR_in     => IIR_connect,
	IIR_out     => signal_out
);


end architecture;


