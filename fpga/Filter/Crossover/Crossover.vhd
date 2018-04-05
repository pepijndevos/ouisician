LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Crossover is
generic(
    W_in : integer := 16;
	 W_coef : integer := 30;   
    B0_low : integer := 706; 
    B1_low : integer := 1411;
    B2_low : integer := 706;
    A0_low : integer := 4194304;
    A1_low : integer := -8233335;
    A2_low : integer := 4041854; 

    B0_high : integer 	:= 4117373; 
    B1_high: integer 	:= -8234746;
    B2_high: integer 	:= 4117373;
    A0_high : integer 	:= 4194304;
    A1_high: integer 	:= -8233335;
    A2_high : integer 	:= 4041854
);
    port (
      main_CLK       : in std_logic;
      Reset          : in std_logic;
      new_val       : in std_logic;                         -- indicates a new input value
      data_in         : in signed (15 downto 0);               
      data_outlow        : out signed (15 downto 0);   -- Output
		data_outhigh        : out signed (15 downto 0)   -- Output
    );
end entity Crossover;

architecture behaviour of Crossover is

component Cascade_Biquad is
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
end component;


begin
Lowpass : Cascade_Biquad
generic map(
    W_in  => W_in,
	 W_coef =>W_coef,  
    B0  => B0_low, 
    B1  => B1_low,
    B2  => B2_low,
    A0  => A0_low,
    A1  => A1_low,
    A2  => A2_low
)
port map (
        main_CLK => main_CLK,
        Reset => Reset,        
        new_val => new_val,        
        data_in => data_in,       
        data_out => data_outlow       
);

Highpass : Cascade_Biquad
generic map(
    W_in  => W_in,
	 W_coef => W_coef,  
    B0  => B0_high, 
    B1  => B1_high,
    B2  => B2_high,
    A0  => A0_high,
    A1  => A1_high,
    A2  => A2_high
)
port map (
        main_CLK => main_CLK,    
        Reset => Reset,      
        new_val => new_val,       
        data_in => data_in,               
        data_out => data_outhigh  
);		
end architecture;