LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Crossovermain is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_outlow        : out signed (15 downto 0);   -- Output
		data_outhigh        : out signed (15 downto 0)   -- Output
    );
end entity Crossovermain;

architecture behaviour of Crossovermain is

component CrossoverLowpass is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_out        : out signed (15 downto 0)   -- Output
    );
end component;

component CrossoverHighpass is
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_out        : out signed (15 downto 0)   -- Output
    );
end component;

begin
Lowpass : CrossoverLowpass
port map (
        main_CLK => main_CLK,
        Reset => Reset,        
        new_val => new_val,        
        data_in => data_in,       
        data_out => data_outlow       
);

Highpass : CrossoverHighpass
port map (
        main_CLK => main_CLK,    
        Reset => Reset,      
        new_val => new_val,       
        data_in => data_in,               
        data_out => data_outhigh  
);		
end architecture;