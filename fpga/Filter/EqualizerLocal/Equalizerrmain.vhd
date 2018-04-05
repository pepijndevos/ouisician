LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Equalizermain is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_outbaseshelve        : out signed (15 downto 0);   -- Output
	data_outmidpeak       : out signed (15 downto 0);   -- Output
	data_outtrebleshelve       : out signed (15 downto 0)   -- Output
	
    );
end entity Equalizermain;

architecture behaviour of Equalizermain is

component baseShelve is
    port (
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        new_val         : in std_logic;       -- indicates a new input value, input from data_over
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

component midPeak is
    port (
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        new_val         : in std_logic;       -- indicates a new input value, input from data_over
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

component trebleShelve is
    port (
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        new_val         : in std_logic;       -- indicates a new input value, input from data_over
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

begin
Basecontrol : baseShelve
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,       
        IIR_out => data_outbaseshelve       
);

Midcontrol : midPeak
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,                     
        IIR_out => data_outmidpeak -- COEFFICIENTS NOT YET SET
);

Treblecontrol : trebleShelve
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,                
        IIR_out => data_outtrebleshelve  
);			
end architecture;