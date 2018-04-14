library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity delayhandler is
	 generic (
		base_addr : integer := 6;
		mychan : std_logic_vector := x"01"
	 );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
		chan   : in STD_LOGIC_VECTOR(7 DOWNTO 0); 
	   filterid : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	   filterdata : in STD_LOGIC_VECTOR(31 DOWNTO 0); 
		
		max_ampl : out unsigned(15 downto 0);
		speed : out unsigned(15 downto 0);
      bl_gain : out integer range 0 to 256;
      ff_gain1 : out integer range 0 to 256;
      fb_gain1 : out integer range 0 to 256;
      ff_gain2 : out integer range 0 to 256;
      fb_gain2 : out integer range 0 to 256;
      ff_gain3 : out integer range 0 to 256;
      fb_gain3 : out integer range 0 to 256;
      offset1  : out unsigned(19 downto 0);
      offset2  : out unsigned(19 downto 0);
      offset3  : out unsigned(19 downto 0)
    );
end;

architecture behavioral of delayhandler is
begin
  process(clk, rst)
  begin
    if rst = '0' then
		bl_gain <= 256;
		ff_gain1 <= 0;
		fb_gain1 <= 0;
		ff_gain2 <= 0;
		fb_gain2 <= 0;
		ff_gain3 <= 0;
		fb_gain3 <= 0;
		max_ampl <= x"0000";
		speed <= x"0000";
		offset1 <= x"0fff0";
		offset2 <= x"0fff0";
		offset3 <= x"0fff0";
    elsif rising_edge(clk) then
	   if chan = mychan then 
			case filterid is
				when std_logic_vector(to_unsigned(0+base_addr, filterid'length)) =>
					max_ampl <= resize(unsigned(filterdata), max_ampl'length);
				when std_logic_vector(to_unsigned(1+base_addr, filterid'length)) =>
					speed <= resize(unsigned(filterdata), speed'length);
				when std_logic_vector(to_unsigned(2+base_addr, filterid'length)) =>
					bl_gain <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(3+base_addr, filterid'length)) =>
					ff_gain1 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(4+base_addr, filterid'length)) =>
					fb_gain1 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(5+base_addr, filterid'length)) =>
					ff_gain2 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(6+base_addr, filterid'length)) =>
					fb_gain2 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(7+base_addr, filterid'length)) =>
					ff_gain3 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(8+base_addr, filterid'length)) =>
					fb_gain3 <= to_integer(unsigned(filterdata));
				when std_logic_vector(to_unsigned(9+base_addr, filterid'length)) =>
					offset1 <= resize(unsigned(filterdata), offset1'length);
				when std_logic_vector(to_unsigned(10+base_addr, filterid'length)) =>
					offset2 <= resize(unsigned(filterdata), offset2'length);
				when std_logic_vector(to_unsigned(11+base_addr, filterid'length)) =>
					offset3 <= resize(unsigned(filterdata), offset3'length);
				when others =>
			end case;
		end if;
    end if;
  end process;

end;
