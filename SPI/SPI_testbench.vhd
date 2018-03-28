library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity SPI_testebench is
end;

architecture testbench of SPI_testebench is
	
	signal reset_n : std_logic := '0';
	signal clk : std_logic := '0';
	signal sclk : std_logic := '0';
	signal ss : std_logic := '0';
    signal mosi : std_logic := '0';
	signal miso : std_logic ;
  component spi_slave_ui
    port (
	
	clk	: IN std_logic; --50Mhz clock	
	
	--UI
	reset_n	: IN STD_LOGIC; --button
	busy	: OUT STD_LOGIC; --LED

	--FROM MASTER
	sclk	: IN STD_LOGIC;  --spi clk from master	
	ss	: IN STD_LOGIC;  --active low slave select
	mosi	: IN STD_LOGIC;  --master out, slave in

	--TO MASTER
	miso	: OUT    STD_LOGIC := 'Z' --master in, slave out
	
    );
  end component;

    
begin
  reset_n <= '1' AFTER 20 ns; -- reset pin
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sclk <= NOT sclk AFTER 10 ns; 
  ss <= NOT ss AFTER 200 ns; 
  mosi <= NOT mosi AFTER 20 ns;
  -- process(sclk)
    -- variable counter: integer := 0;
  -- begin
    -- if rising_edge(sclk) then
      -- counter := counter + 1;
      -- if counter = 10 then
        -- word <= x"3fff";
      -- else
        -- word <= x"0000";
      -- end if;
  -- end process;
    -- end if;

  ui : spi_slave_ui port map (
    reset_n => reset_n,
    clk => clk,
    sclk => sclk,
    ss => ss,
    mosi => mosi,
	miso => miso
  );
end;