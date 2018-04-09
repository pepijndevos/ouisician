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

  component comb
    generic (
      bl_gain : integer := 256;
      ff_gain : integer := 0;
      fb_gain : integer := 128
    );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      offset  : in unsigned(11 downto 0);
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
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
    offset => x"010",
    word => word,
    resp => resp
  );
end;
