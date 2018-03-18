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

architecture mean of filter is
begin
  process(sndclk)
  type buf_type is array (0 to 3) of signed(15 downto 0);
  variable buf : buf_type;
  begin
    if rising_edge(sndclk) then
      buf := word & buf(0 to 2);
      resp <= buf(0)/4 + buf(1)/2 + buf(2)/8 + buf(3)/8;
    end if;
  end process;

end;
