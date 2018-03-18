library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity filter is
    port (
      clk    : in std_logic;
      sndclk : in std_logic;
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture allpass of filter is
begin

  process(sndclk)
  begin
    if rising_edge(sndclk) then
      resp <= word;
    end if;
  end process;

end;
