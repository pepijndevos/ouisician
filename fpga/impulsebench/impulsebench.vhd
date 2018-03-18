library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity impulsebench is
end;

architecture testbench of impulsebench is

	signal clk : std_logic := '0';
	signal sndclk : std_logic := '0';
	signal word : signed(15 downto 0);
  signal resp : signed(15 downto 0);

  component filter
    port (
      clk    : in std_logic;
      sndclk : in std_logic;
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
  end component;

    
begin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sndclk <= NOT sndclk AFTER 20.83 us; -- "audio clock"; 48 kHz klok

  process(sndclk)
    variable counter: integer := 0;
  begin
    if rising_edge(sndclk) then
      counter := counter + 1;
      if counter = 10 then
        word <= x"3fff";
      else
        word <= x"0000";
      end if;
    end if;
  end process;

  filter_inst : filter port map (
    clk => clk,
    sndclk => sndclk,
    word => word,
    resp => resp
  );
end;
