library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity speaker is
  port(CLOCK_50    : in std_logic;
		 LEDR        : out std_logic_vector(9 downto 0);
		 GPIO_DIN    : in std_logic;
		 GPIO_LRCK   : in std_logic;
		 GPIO_BCLK   : in std_logic;
		 GPIO_DOUT   : out std_logic
	   );
end speaker;

architecture Behavioral of speaker is
	signal counter : unsigned(31 downto 0);
begin

process(GPIO_LRCK)
begin
	if rising_edge(GPIO_LRCK) then
		counter <= counter+1;
		LEDR <= std_logic_vector(counter(9 downto 0));
	end if;
end process;

end Behavioral;