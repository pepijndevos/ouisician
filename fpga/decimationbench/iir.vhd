library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity iir is
Generic (
    w_in : integer := 16;
    w_coef : integer := 16;

    B0 : integer := 300; 
    B1 : integer := 600;
    B2 : integer := 300;
    A0 : integer := 1024;
    A1 : integer := 0;
    A2 : integer := 176
);
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture behavioral of iir is
begin
  process(clk, rst)
  constant cB0 : signed(w_coef-1 downto 0) := to_signed(B0, w_coef); 
  constant cB1 : signed(w_coef-1 downto 0) := to_signed(B1, w_coef);
  constant cB2 : signed(w_coef-1 downto 0) := to_signed(B2, w_coef);
  constant cA0 : signed(w_coef-1 downto 0) := to_signed(A0, w_coef);
  constant cA1 : signed(w_coef-1 downto 0) := to_signed(A1, w_coef);
  constant cA2 : signed(w_coef-1 downto 0) := to_signed(A2, w_coef);
  variable X2 : signed(w_in+w_coef-1 downto 0);
  variable X1 : signed(w_in+w_coef-1 downto 0);
  variable Y2 : signed(w_in+w_coef-1 downto 0);
  variable Y1 : signed(w_in+w_coef-1 downto 0);
  variable acc : signed(w_in+w_coef-4 downto 0);
  begin
    if rst = '0' then
      X1 := to_signed(0, X1'length);
      X2 := to_signed(0, X2'length);
      Y1 := to_signed(0, Y1'length);
      Y2 := to_signed(0, Y2'length);
    elsif rising_edge(clk) then
      acc := resize(cB2 * X2, acc'length);
      acc := acc + resize(cB1 * X1, acc'length);
      X2 := X1;
      acc := acc + resize(cB0 * word, acc'length);
      X1 := resize(word, X1'length);
      acc := acc - resize(cA2 * Y2, acc'length);
      acc := acc - resize(cA1 * Y1, acc'length);
      Y2 := Y1;
      Y1 := resize(acc/cA0, Y1'length);
      resp <= resize(Y1, resp'length);
    end if;
  end process;

end;
