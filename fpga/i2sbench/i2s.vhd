library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity i2s is
    port (
      rst    : in std_logic;
      bclk    : in std_logic;
      rlclk : in std_logic;
      din : in std_logic;
      dout : out std_logic;
      win1   : in signed(15 downto 0);
      win2   : in signed(15 downto 0);
      win3   : in signed(15 downto 0);
      win4   : in signed(15 downto 0);
      wout1   : out signed(15 downto 0);
      wout2   : out signed(15 downto 0);
      wout3   : out signed(15 downto 0);
      wout4   : out signed(15 downto 0)
    );
end;

architecture behavioral of i2s is
begin
  process(bclk, rlclk, rst)
    variable buf : std_logic_vector(63 downto 0);
    variable lastrl : std_logic;
  begin
    if rst = '0' then
      buf := (others => '0');
      lastrl := '0';
    elsif rising_edge(bclk) then
      buf := buf(62 downto 0) & din;
      if lastrl = '0' and rlclk = '1' then
        wout1 <= signed(buf(63 downto 48));
        wout2 <= signed(buf(47 downto 32));
        wout3 <= signed(buf(31 downto 16));
        wout4 <= signed(buf(15 downto 0));
      end if;
      lastrl := rlclk;
    end if;
  end process;

  process(bclk, rlclk, rst)
    variable buf : std_logic_vector(63 downto 0);
    variable lastrl : std_logic;
  begin
    if rst = '0' then
      buf := (others => '0');
      lastrl := '0';
    elsif falling_edge(bclk) then
	   if lastrl = '0' and rlclk = '1' then
        buf(63 downto 48) := std_logic_vector(win1);
        buf(47 downto 32) := std_logic_vector(win2);
        buf(31 downto 16) := std_logic_vector(win3);
        buf(15 downto 0)  := std_logic_vector(win4);
      end if;
	   dout <= buf(63);
      buf := buf(62 downto 0) & '0';
      lastrl := rlclk;
    end if;
  end process;
end;
