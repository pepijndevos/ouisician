library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity speaker is
  port(CLOCK_50  : in std_logic;
		 LEDR      : out std_logic_vector(9 downto 0)
	   );
end speaker;

architecture Behavioral of speaker is
	signal counter : unsigned(31 downto 0);
begin

process(CLOCK_50)
begin
	if rising_edge(CLOCK_50) then
		counter <= counter+1;
		LEDR <= std_logic_vector(counter(31 downto 22));
	end if;
end process;

end Behavioral;