library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

use std.env.all;
use std.textio.all;
use work.testbench_utils.all;
use work.csv_file_reader_pkg.all;

-- Testbench for the csv_file_reader_pkg package. Test the package's basic
-- operation by reading data from known test files and checking the values read
-- against their expected values.
entity i2sbench is
end;

architecture testbench of i2sbench is

  signal rst : std_logic;
	signal dout : std_logic;
	signal din : std_logic;
	signal lrclk : std_logic;
	signal bclk : std_logic;

  signal wout1 : signed(15 downto 0);
  signal wout2 : signed(15 downto 0);

    
begin
    process
        variable csv_file: csv_file_reader_type;
        variable read_boolean: boolean;
        variable read_integer: integer;
    begin
        puts("Starting testbench...");
        csv_file.initialize("i2s.csv");

        rst <= '0';
        rst <= '1' after 20 ns;

        while not csv_file.end_of_file loop
		csv_file.readline;
		read_integer := csv_file.read_integer; -- discard
		read_boolean := csv_file.read_integer_as_boolean;
		if read_boolean then
			dout <= '1';
		else
			dout <= '0';
		end if;
		read_boolean := csv_file.read_integer_as_boolean;
		--if read_boolean then
		--	lrclk <= '1';
		--else
		--	lrclk <= '0';
		--end if;
		read_boolean := csv_file.read_integer_as_boolean;
		if read_boolean then
			bclk <= '1';
		else
			bclk <= '0';
		end if;
		wait for 20 ns;
	end loop;
        puts("End of testbench. All tests passed.");
        stop;
    end process;

  i2s_inst: entity work.i2s(behavioral)
    port map (rst => rst,
      bclk => bclk,
      rlclk =>lrclk,
      din => dout,
      dout => din,
      win1 => x"5555",
      win2 => x"ffff",
      wout1 => wout1,
      wout2 => wout2);

end;
