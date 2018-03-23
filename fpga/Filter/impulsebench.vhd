library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity impulsebench is
end;

architecture testbench of impulsebench is

	signal clk : std_logic := '0';
	signal sndclk : std_logic := '0';
	signal word : signed(15 downto 0);
        signal resp : signed(15 downto 0);
	signal reset : std_logic :='1';

component IIR_Implement
Generic (
    w_out : integer := 16;
    w_in : integer := 16;
    w_coef: integer:= 20;
	
    B0 : integer := 6 ; -- scaled by 2^16, described by 2^19, 
    B1 : integer := 13 ;
    B2 : integer :=  6;
    A1 : integer := -132892;
    A2 : integer :=  67381 
);
    Port ( iCLK : in STD_LOGIC; --50mhz internal clock
	   sCLK : in STD_LOGIC; --sample clock at 48khz
           Reset : in STD_LOGIC;
           IIR_in : in signed(15 downto 0);
           IIR_out : out signed(15 downto 0)   
);
end component;

    
begin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok

  process(sndclk)
    variable counter: integer := 0;
  begin
    if rising_edge(sndclk) then
      counter := counter + 1;
      if counter = 10 then
        word <= x"3fff";
      else
        word <= x"0000";
      end if;
    end if;
  end process;

  filter_inst : IIR_Implement port map (
    sCLK => sndclk,
    iCLK => clk,
    IIR_in => word,
    IIR_out => resp,
    Reset => reset
  );
end;
