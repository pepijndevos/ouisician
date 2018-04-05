library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity i2s is
    port (
      rst    : in std_logic;
      bclk    : in std_logic;
      rlclk : out std_logic;
      din : in std_logic;
      dout : out std_logic;
      win1   : in signed(15 downto 0);
      win2   : in signed(15 downto 0);
      wout1   : out signed(15 downto 0);
      wout2   : out signed(15 downto 0)
    );
end;

architecture behavioral of i2s is
	signal counter : integer range 0 to 31;
begin
  rlclk <= '0' when counter < 16 else '1';
  process(bclk, rst)
    variable buf : std_logic_vector(31 downto 0);
    variable lastrl : std_logic;
  begin
    if rst = '0' then
      buf := (others => '0');
      lastrl := '0';
    elsif rising_edge(bclk) then
      buf := buf(30 downto 0) & din;
      if counter = 0 then
        wout1 <= signed(buf(31 downto 16));
        wout2 <= signed(buf(15 downto 0));
      end if;
    end if;
  end process;

  process(bclk, rst)
    variable buf : std_logic_vector(31 downto 0);
    variable lastrl : std_logic;
  begin
    if rst = '0' then
      buf := (others => '0');
      lastrl := '0';
    elsif falling_edge(bclk) then
	   dout <= buf(31);
      buf := buf(30 downto 0) & '0';
	   if counter = 31 then
        buf(31 downto 16) := std_logic_vector(win1);
        buf(15 downto 0)  := std_logic_vector(win2);
        counter <= 0;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;
end;
