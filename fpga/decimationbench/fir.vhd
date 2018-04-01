library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;

entity fir is
Generic (
    coef_scale : integer;
    w_acc : integer;
    w_in : integer := 16;
    w_out : integer := 16;
    coef : array_of_integers
);
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      word   : in signed(w_in-1 downto 0);
      resp   : out signed(w_out-1 downto 0)
    );
end;

architecture behavioral of fir is
begin
  process(clk, rst)
    variable lastsnd : std_logic;
    variable counter : integer range coef'low to coef'high+1;
    variable acc : signed(w_acc-1 downto 0);
    type buf_type is array (coef'low to coef'high) of signed(w_in-1 downto 0);
    variable buf : buf_type;
  begin
    if rst = '0' then
      lastsnd := '0';
      counter := coef'low;
      acc := to_signed(0, acc'length);
      buf := (others => to_signed(0, word'length));
    elsif rising_edge(clk) then
      if lastsnd = '0' and sndclk = '1' then
        counter := coef'low;
        acc := to_signed(0, acc'length);
        buf := word & buf(coef'low to coef'high-1);
      end if;
      if counter <= coef'high then
        if w_in = 1 then 
          if buf(counter) = "1" then
            acc := acc + coef(counter);
          else
            acc := acc - coef(counter);
          end if;
        else
          acc := acc + buf(counter) * coef(counter);
        end if;
        counter := counter + 1;
      else
        resp <= resize(acc/coef_scale, resp'length);
      end if;
      lastsnd := sndclk;
    end if;
  end process;

end;
