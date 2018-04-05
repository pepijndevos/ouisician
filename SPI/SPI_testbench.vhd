library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity SPI_testebench is
GENERIC(
    d_width : INTEGER := 24
    ); --data bus width
PORT(
	receiveddata : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
	filter_ctrl_cha1  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha2  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha3  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha4  : out std_logic_vector(15 downto 0)
);
end;

architecture testbench of SPI_testebench is
	
	signal reset_n : std_logic := '0';
	signal clk : std_logic := '0';
	signal sclk : std_logic := '0';
	signal ss : std_logic := '0';
    	signal mosi : std_logic := '0';
	signal miso : std_logic ;
	signal output : std_logic_vector(d_width-1 DOWNTO 0) := "000010100000010100000000";
	--SIGNAL rx_data	: STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) := (OTHERS => '0');  --receive register output to logic


  component spi_slave_ui
    port (
	
	clk	: IN std_logic; --50Mhz clock	
	
	--UI
	reset_n	: IN STD_LOGIC; --button
	--dig0, dig1, dig2 , dig3 , dig4 , dig5 : OUT std_logic_vector(6 DOWNTO 0); 
	
	--FROM MASTER
	sclk	: IN STD_LOGIC;  --spi clk from master	
	ss	: IN STD_LOGIC;  --active low slave select
	mosi	: IN STD_LOGIC;  --master out, slave in
	--TO REST
	receiveddata : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
	filter_ctrl_cha1  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha2  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha3  : out std_logic_vector(15 downto 0);
	filter_ctrl_cha4  : out std_logic_vector(15 downto 0);
	--TO MASTER
	output : in std_logic_vector(d_width-1 DOWNTO 0);
	miso	: out STD_LOGIC := 'Z'  --master in, slave out
	

    );
  end component;

    begin
  reset_n <= '1' after 50ns;
  --reset_n <= NOT reset_n AFTER 100000000 ns; -- "fast clock"; 50 MHz klok
  clk <= NOT clk AFTER 10 ns; -- "fast clock"; 50 MHz klok
  sclk <= NOT sclk AFTER 10 ns; 
  ss <= NOT ss AFTER 500 ns; 
  --output <= NOT output AFTER 20 ns;
  mosi <= NOT mosi AFTER 10 ns;
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
    output => output,
    mosi => mosi,
	miso => miso,
	filter_ctrl_cha1=>filter_ctrl_cha1,
	filter_ctrl_cha2=>filter_ctrl_cha2,
	filter_ctrl_cha3=>filter_ctrl_cha3,
	filter_ctrl_cha4=>filter_ctrl_cha4,
	receiveddata=>receiveddata
  );
end;