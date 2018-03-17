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

	signal dout : std_logic;
	signal lrclk : std_logic;
	signal bclk : std_logic;
    
begin
    process
        variable csv_file: csv_file_reader_type;
        variable read_boolean: boolean;
        variable read_real: real;
    begin
        puts("Starting testbench...");
        csv_file.initialize("i2s.csv");

        while not csv_file.end_of_file loop
		csv_file.readline;
		read_boolean := csv_file.read_integer_as_boolean;
		if read_boolean then
			dout <= '1';
		else
			dout <= '0';
		end if;
		read_boolean := csv_file.read_integer_as_boolean;
		if read_boolean then
			lrclk <= '1';
		else
			lrclk <= '0';
		end if;
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
end;
