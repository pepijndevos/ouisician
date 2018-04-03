LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity CrossoverLowpass is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_out        : out signed (15 downto 0)   -- Output
    );
end entity CrossoverLowpass;

architecture behaviour of CrossoverLowpass is

--Component initiate
component IIRDF1 is
    generic (
        INPUT_WIDTH : integer := 32;
        QFORMAT   : integer := 30;  
    B0 : real := 0.00009506; 
    B1 : real := 0.00019012;
    B2 : real := 0.00009506;
    A1 : real := -1.97223373;
    A2 : real := 0.972613969;
    A0 : real := 1.0
    );
        
    port (
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        new_val         : in std_logic;                         -- indicates a new input value
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

--Connection signals
signal signal_in : signed(15 downto 0) := (others=>'0');
signal IIR_connect : signed(15 downto 0) := (others=>'0');
signal signal_out : signed(15 downto 0) := (others=>'0');

begin
signal_in <= data_in;
data_out <=  signal_out;
IIR1_LPF : IIRDF1
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	new_val    => new_val ,
	IIR_in     => signal_in,
	IIR_out     => IIR_connect
);

IIR2_LPF : IIRDF1
port map (
	iCLK        => main_CLK,
	iRESET_N    => Reset,
	new_val    => new_val  ,
	IIR_in     => signal_in,
	IIR_out     => signal_out
);


end architecture;


