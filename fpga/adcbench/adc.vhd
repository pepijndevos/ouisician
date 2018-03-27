library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity adc is
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      data   : in std_logic;
      word   : out signed(15 downto 0)
    );
end;

architecture behavioral of adc is
begin
  process(clk, rst)
    variable buf : std_logic_vector(1023 downto 0);
    variable sum : unsigned(11 downto 0);
    variable data_num : unsigned(0 downto 0);
    variable last_num : unsigned(0 downto 0);
  begin
    if rst = '0' then
      buf := (others => '0');
      sum := to_unsigned(0, sum'length);
    elsif rising_edge(clk) then
      data_num(0) := buf(buf'low);
      last_num(0) := buf(buf'high);
      sum := sum - last_num + data_num;
      word <= resize((signed(resize(sum, word'length)) - x"200")*64, word'length);
      buf := buf(buf'high-1 downto buf'low) & data;
    end if;
  end process;

end;
