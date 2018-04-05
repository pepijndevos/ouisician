library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;

entity adc is
    port (
      rst    : in std_logic;
      clk    : in std_logic;
		sndclk : out std_logic;
      data   : in std_logic;
      word   : out signed(15 downto 0)
    );
end;

architecture behavioral of adc is
	signal interclk : std_logic := '0';
	signal input : signed(15 downto 0);
	signal inter : signed(15 downto 0);

begin
  process(clk, rst)
  begin
    if rst = '0' then
    elsif rising_edge(clk) then
		if data = '1' then
	     input <= to_signed(16384, input'length);
		else
	     input <= to_signed(-16384, input'length);
		end if;
    end if;
  end process;
  
	iir_inst: entity work.iir(behavioral)
		generic map (
		    w_in => 16,
			 w_coef => 22,
			 B0 => 2,
			 B1 => 3,
			 B2 => 2,
			 A0 => 1048576,
			 A1 => -2093425,
			 A2 => 1044856)
		port map (
			rst => rst,
			clk => clk,
			word => input,
			resp => word);

end;
