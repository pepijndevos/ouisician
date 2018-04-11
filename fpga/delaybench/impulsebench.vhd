library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity impulsebench is
end;

architecture testbench of impulsebench is

	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal sndclk : std_logic := '0';
	signal word : signed(15 downto 0) := x"0000";
  signal resp : signed(15 downto 0);
  signal offset : unsigned(9 downto 0);

  component comb
    port (
      bl_gain : integer range 0 to 255;
      ff_gain1 : integer range 0 to 255;
      fb_gain1 : integer range 0 to 255;
      ff_gain2 : integer range 0 to 255;
      fb_gain2 : integer range 0 to 255;
      ff_gain3 : integer range 0 to 255;
      fb_gain3 : integer range 0 to 255;
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      offset1  : in unsigned(19 downto 0);
      offset2  : in unsigned(19 downto 0);
      offset3  : in unsigned(19 downto 0);
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
  end component;

  component triangle is
    generic(
      width : integer := 10;
      speed : integer := 2**5
    );
    port(
      rst : in std_logic;
      clk : in std_logic;
      data : out unsigned(width-1 downto 0)
    );
  end component;
    
begin
  rst <= '1' AFTER 200 ns; -- reset pin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok

  process(sndclk)
    variable counter: integer := 0;
  begin
    if rising_edge(sndclk) then
      counter := counter + 1;
      if counter = 10 then
        word <= x"0fff";
      else
        word <= x"0000";
      end if;
    end if;
  end process;

  filter_inst : comb port map (
    rst => rst,
    clk => clk,
    sndclk => sndclk,
    bl_gain => 255,
    ff_gain1 => 255,
    fb_gain1 => 0,
    ff_gain2 => 255,
    fb_gain2 => 0,
    ff_gain3 => 255,
    fb_gain3 => 0,
    offset1 => x"00020",
    offset2 => x"00040",
    offset3 => x"00068",
    word => word,
    resp => resp
  );

  triangle_inst : triangle port map (
    rst => rst,
    clk => clk,
    data => offset
  );
end;
