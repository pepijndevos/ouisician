library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity triangle is
port (
	rst : in std_logic;
	clk : in std_logic;
	max_ampl : in unsigned(15 downto 0);
	speed : in unsigned(15 downto 0);
	data : out unsigned(15 downto 0)
);
end triangle;

architecture behavioural of triangle is
begin

process(clk,rst)
  variable clock_counter : integer:= 0;
  variable triangle_counter : integer := 0;
  variable direction: std_logic := '0';
begin
  if (rst = '0') then
    clock_counter := 0;
    triangle_counter := 0;
    direction := '0';
  elsif(rising_edge(clk)) then
    if max_ampl = x"0000" then
		data <= to_unsigned(0, data'LENGTH);
	 elsif (clock_counter = speed ) then 
      clock_counter := 0;
      if (direction = '0') then
        triangle_counter := triangle_counter + 1;
        data <= to_unsigned(triangle_counter,data'LENGTH);
        if(triangle_counter = max_ampl) then
          direction := '1';
        end if;
      end if;
      if(direction = '1') then
        triangle_counter := triangle_counter - 1;
        data <= to_unsigned(triangle_counter,data'LENGTH);
        if(triangle_counter = 0) then
          direction := '0';
        end if;
      end if;
    else
      clock_counter := clock_counter + 1;
    end if;
  end if;
end process;

end behavioural;
