LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Equalizermain is
generic(
    W_in : integer := 16;
	 W_coef : integer := 17; --14; -- max matlab coefficient number must fit in this size
    B0_base : integer := 4185;
    B1_base : integer := -7958;
    B2_base : integer := 3792;
    A0_base : integer := 4096;
    A1_base : integer := -7965;
    A2_base : integer := 3875;

    B0_mid : integer 	:= 4874;
    B1_mid: integer 	:= -5929;
    B2_mid: integer 	:= 2599;
    A0_mid : integer 	:= 4096;
    A1_mid: integer 	:= -5929;
    A2_mid : integer 	:= 3377;

    B0_treble: integer 	:= 8823;
    B1_treble: integer 	:= -8557;
    B2_treble: integer 	:= 3650;
    A0_treble: integer 	:= 4096;
    A1_treble: integer 	:= -1367;
    A2_treble : integer := 1187
);
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

component IIRDF1 is
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
        iCLK            : in std_logic;
        iRESET_N        : in std_logic;
        new_val         : in std_logic;       -- indicates a new input value, input from data_over
        IIR_in          : in signed (15 downto 0);   -- singed is expected             
        IIR_out         : out signed (15 downto 0)   -- Output
    );
end component;

begin
Basecontrol : IIRDF1
generic map(
    W_in  => W_in,
	 W_coef => W_coef,  
    B0  => B0_base, 
    B1  => B1_base,
    B2  => B2_base,
    A0  => A0_base,
    A1  => A1_base,
    A2  => A2_base
)
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,       
        IIR_out => data_outbaseshelve       
);

Midcontrol : IIRDF1
generic map(
    W_in  => W_in,
	 W_coef => W_coef,  
    B0  => B0_mid, 
    B1  => B1_mid,
    B2  => B2_mid,
    A0  => A0_mid,
    A1  => A1_mid,
    A2  => A2_mid
)
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,                     
        IIR_out => data_outmidpeak -- COEFFICIENTS NOT YET SET
);

Treblecontrol : IIRDF1
generic map(
    W_in  => W_in,
	 W_coef => W_coef,  
    B0  => B0_treble, 
    B1  => B1_treble,
    B2  => B2_treble,
    A0  => A0_treble,
    A1  => A1_treble,
    A2  => A2_treble
)
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,                
        IIR_out => data_outtrebleshelve  
);			
end architecture;