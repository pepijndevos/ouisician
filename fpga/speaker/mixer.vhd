library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity mixer is
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      word1   : in signed(15 downto 0);
      word2   : in signed(15 downto 0);
      word3   : in signed(15 downto 0);
      word4   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture behavioral of mixer is
begin
  process(clk, rst)
  begin
    if rst = '0' then
      resp <= to_signed(0, resp'length);
    elsif rising_edge(clk) then
      resp <= (word1 + word2) + (word3 + word4);
    end if;
  end process;

end;
