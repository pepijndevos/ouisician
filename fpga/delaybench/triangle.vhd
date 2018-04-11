library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity triangle is
generic(
	width : integer := 8;
	speed : integer := 2**14
);
port(
	rst : in std_logic;
	clk : in std_logic;
	data : out unsigned(15 downto 0)
);
end triangle;

architecture behavioural of triangle is
begin

process(clk,rst)
  constant max_ampl : integer := 2**width-1;
  variable clock_counter : integer range 0 to speed:= 0;
  variable triangle_counter : integer range 0 to max_ampl := 0;
  variable direction: std_logic := '0';
begin
  if (rst = '0') then
    clock_counter := 0;
    triangle_counter := 0;
  elsif(rising_edge(clk)) then
    if (clock_counter = speed ) then 
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
