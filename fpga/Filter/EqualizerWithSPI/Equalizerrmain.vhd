LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL;  

entity Equalizermain is
generic(
    W_in : integer := 16;
	 W_coef : integer := 17; --14; -- max matlab coefficient number must fit in this size

-- ** 10 dB gain for all filters **
--    B0_base : integer := 4185;
--    B1_base : integer := -7958;
--    B2_base : integer := 3792;
--    A0_base : integer := 4096;
--    A1_base : integer := -7965;
--    A2_base : integer := 3875;
--
--    B0_mid : integer 	:= 4874;
--    B1_mid: integer 	:= -5929;
--    B2_mid: integer 	:= 2599;
--    A0_mid : integer 	:= 4096;
--    A1_mid: integer 	:= -5929;
--    A2_mid : integer 	:= 3377;
--
--    B0_treble: integer 	:= 8823;
--    B1_treble: integer 	:= -8557;
--    B2_treble: integer 	:= 3650;
--    A0_treble: integer 	:= 4096;
--    A1_treble: integer 	:= -1367;
--    A2_treble : integer := 1187

-- ** initialize: all-pass for all filters **
    B0_base : integer := 4096;
    B1_base : integer := 0;
    B2_base : integer := 0;
    A0_base : integer := 4096;
    A1_base : integer := 0;
    A2_base : integer := 0;

    B0_mid : integer 	:= 4096;
    B1_mid: integer 	:= -5929;
    B2_mid: integer 	:= 3377;
    A0_mid : integer 	:= 4096;
    A1_mid: integer 	:= -5929;
    A2_mid : integer 	:= 3377;

    B0_treble: integer 	:= 4096;
    B1_treble: integer 	:= 0;
    B2_treble: integer 	:= 0;
    A0_treble: integer 	:= 4096;
    A1_treble: integer 	:= 0;
    A2_treble : integer := 0
);
    port (
        main_CLK       : in std_logic;
        Reset          : in std_logic;
        new_val       : in std_logic;                         -- indicates a new input value
        data_in         : in signed (15 downto 0);               
        data_outbaseshelve        : out signed (15 downto 0);   -- Output
	data_outmidpeak       : out signed (15 downto 0);   -- Output
	data_outtrebleshelve       : out signed (15 downto 0);   -- Output
	chanEQ : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridEQ : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataEQ : in STD_LOGIC_VECTOR(31 DOWNTO 0)
	
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
        IIR_out         : out signed (15 downto 0);   -- Output
	A0port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	B2port : in STD_LOGIC_VECTOR(23 DOWNTO 0);
	coefficientFLAG : in STD_LOGIC
    );
end component;

component SPImessageHandler is

    port (
	iCLK            : in std_logic;
	iRESET_N        : in std_logic;
	chanHandler : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filteridHandler : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	filterdataHandler : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	A0LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2LOW : out STD_LOGIC_VECTOR(23 DOWNTO 0);

	A0MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2MID : out STD_LOGIC_VECTOR(23 DOWNTO 0);

	A0HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A1HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	A2HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B0HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	B1HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);	
	B2HIGH : out STD_LOGIC_VECTOR(23 DOWNTO 0);
	
	flagLOW : out STD_LOGIC := '0'; -- these flags are there to indicate that new coefficients have been send
	flagMID : out STD_LOGIC := '0';
	flagHigh : out STD_LOGIC := '0'
    );
end component;

signal A0HIGH_temp, A1HIGH_temp, A2HIGH_temp, B0HIGH_temp, B1HIGH_temp, B2HIGH_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal A0MID_temp, A1MID_temp, A2MID_temp, B0MID_temp, B1MID_temp, B2MID_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal A0LOW_temp, A1LOW_temp, A2LOW_temp, B0LOW_temp, B1LOW_temp, B2LOW_temp : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal chanHandler_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal filteridHandler_temp : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal filterdataHandler_temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal flagLOW_temp, flagMID_temp, flagHIGH_temp : STD_LOGIC;

begin

chanHandler_temp <= chanEQ;
filteridHandler_temp <= filteridEQ;
filterdataHandler_temp <= filterdataEQ;

SPImessageDecoder : SPImessageHandler
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,
	chanHandler => chanHandler_temp, 
	filteridHandler => filteridHandler_temp,
	filterdataHandler => filterdataHandler_temp,      
	A0LOW => A0LOW_temp,
	A1LOW => A1LOW_temp,
	A2LOW => A2LOW_temp,
	B0LOW => B0LOW_temp,
	B1LOW => B1LOW_temp,
	B2LOW => B2LOW_temp,

	A0MID => A0MID_temp,
	A1MID => A1MID_temp,
	A2MID => A2MID_temp,
	B0MID => B0MID_temp,
	B1MID => B1MID_temp,
	B2MID => B2MID_temp,

	A0HIGH => A0HIGH_temp,
	A1HIGH => A1HIGH_temp,
	A2HIGH => A2HIGH_temp,
	B0HIGH => B0HIGH_temp,
	B1HIGH => B1HIGH_temp,
	B2HIGH => B2HIGH_temp,
	flagLOW => flagLOW_temp,
	flagMID => flagMID_temp,
	flagHIGH => flagHIGH_temp
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
        IIR_out => data_outtrebleshelve,
	A0port => A0HIGH_temp,
	A1port => A1HIGH_temp,
	A2port => A2HIGH_temp,
	B0port => B0HIGH_temp,
	B1port => B1HIGH_temp,
	B2port => B2HIGH_temp,
	coefficientFLAG => flagHIGH_temp
);
			

Basecontrol : IIRDF1
generic map(
    W_in  => W_in,
    W_coef => W_coef,  
    B0  => B0_base,
    B1  => B1_base,
    B2  => B2_base,
    A0 => A0_base,
    A1  => A1_base,
    A2  => A2_base
)
port map (
        iCLK => main_CLK,
        iRESET_N => Reset,        
        new_val => new_val,        
        IIR_in => data_in,       
        IIR_out => data_outbaseshelve,
	A0port => A0LOW_temp,
	A1port => A1LOW_temp,
	A2port => A2LOW_temp,
	B0port => B0LOW_temp,
	B1port => B1LOW_temp,
	B2port => B2LOW_temp,
	coefficientFLAG => flagLOW_temp
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
        IIR_out => data_outmidpeak,
	A0port => A0MID_temp,
	A1port => A1MID_temp,
	A2port => A2MID_temp,
	B0port => B0MID_temp,
	B1port => B1MID_temp,
	B2port => B2MID_temp,
	coefficientFLAG => flagMID_temp
);

end architecture;