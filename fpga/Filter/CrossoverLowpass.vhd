LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Crossover_LPF is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        samp_CLK       : in std_logic;                         -- indicates a new input value
        IIR_in         : in signed (15 downto 0);               
        IIR_out        : out signed (15 downto 0)   -- Output
    );
end entity Crossover_LPF;

architecture behaviour of Crossover_LPF is

--Component initiate
component IIRDF1 is
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
        sCLK            : in std_logic;                         -- indicates a new input value
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

--Connection signals
signal signal_in : signed(15 downto 0) := (others=>'0');
signal IIR_connect : signed(15 downto 0) := (others=>'0');
signal signal_out : signed(15 downto 0) := (others=>'0');

begin


IIR1_LPF : IIRDF1
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	sCLK        => samp_CLK,
	IIR_in     => signal_in,
	IIR_out     => IIR_connect
);

IIR2_LPF : IIRDF1
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	sCLK        => samp_CLK,
	IIR_in     => signal_in,
	IIR_out     => signal_out
);

end architecture;


