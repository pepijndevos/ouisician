LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY normalization IS
	PORT (clk, reset : IN std_logic;
			amplification1, amplification12, amplification3, amplification4 : IN integer range 0 to 128;
			led : OUT std_logic);
			ic : OUT std_logic_vector(7 DOWNTO 0);
END ENTITY normalization;

-- up_down, change resistence '0' = down
-- chip_select, allow change restance if '0' = on  
-- mode_select, allow independent change '0' = nonindependent, '1' = independent
-- dacsel, '0' = rdac 1, '1' = rdac 2

--ic = (up_down1, chip_select1, mode_select1, dacsel1, up_down2, chip_select2, mode_select2, dacsel2)

ARCHITECTURE bhv OF normalization IS
	FUNCTION pot_control (pot_select_ic_1 : std_logic, pot_select_ic_2 : std_logic, des_amp_ic_1 : integer, des_amp_ic_2 : integer,cur_amp_ic_1 : integer, cur_amp_ic_2 : integer) 
				RETURN std_logic_vector(7 DOWNTO 0) IS
		SIGNAL ic_func : std_logic_vector(7 DOWNTO 0);
	BEGIN
		IF pot_select_ic_1 == '0' THEN
			-- ic 1 pot 1
			IF (des_amp_ic_1 - cur_amp_ic_1) == 0 THEN
				ic_func(7 DOWNTO 4) <= "1110";
			ELSIF (des_amp_ic_1 - cur_amp_ic_1) > 0 THEN
				ic_func(7 DOWNTO 4) <= "1010";
			ELSE
				ic_func(7 DOWNTO 4) <= "0010";
			END IF;
		ELSE
			-- ic 1 pot 2
			IF (des_amp_ic_1 - cur_amp_ic_1) == 0 THEN
				ic_func(7 DOWNTO 4) <= "1111";
			ELSIF (des_amp_ic_1 - cur_amp_ic_1) > 0 THEN
				ic_func(7 DOWNTO 4) <= "1011";
			ELSE
				ic_func(7 DOWNTO 4) <= "0011";
			END IF;
		END IF;

		IF pot_select_ic_2 == '0' THEN
			-- ic 2 pot 1
			IF (des_amp_ic_2 - cur_amp_ic_2) == 0 THEN
				ic_func(3 DOWNTO 0) <= "1110";
			ELSIF (des_amp_ic_2 - cur_amp_ic_2) > 0 THEN
				ic_func(3 DOWNTO 0) <= "1010";
			ELSE
				ic_func(3 DOWNTO 0) <= "0010";
			END IF;
		ELSE
			-- ic 2 pot 2
			IF (des_amp_ic_2 - cur_amp_ic_2) == 0 THEN
				ic_func(3 DOWNTO 0) <= "1111";
			ELSIF (des_amp_ic_2 - cur_amp_ic_2) > 0 THEN
				ic_func(3 DOWNTO 0) <= "1011";
			ELSE
				ic_func(3 DOWNTO 0) <= "0011";
			END IF;
		END IF;
		RETURN ic;
	END pot_control;
	
		SIGNAL counter0_0, counter0_1, counter1, counter2, counter3, counter4 : integer range 0 to 256;
		SIGNAL start_up, reset_resistance_processing : std_logic := '0';
		SIGNAL reset_amp : integer range 0 to 128 := 64;
		SIGNAL max_amp : integer range 0 to 128 := 128;
		SIGNAL temp_ic : std_logic_vector(7 DOWNTO 0);

	BEGIN
		
	PROCESS(clk,reset)

	BEGIN
		-- NO VHDL CODE HERE
		IF reset='0' THEN
		counter0 <= 0;
		counter1 <= 0;
		counter2 <= 0;
		counter3 <= 0;
		counter4 <= 0;
		clk_1Hz <= '0'; 
		start_up <= '0';
		
		led<='0';
		
		
		ELSIF falling_edge(clk) THEN
			
			IF start_up <= '0' AND THEN 
				reset_restance_start <= '1';
				reset_resistance_processing <= '1';
				counter0_0 = 0;
				counter0_1 = 0;

			ELSE
				counter1 <= amplification1;
				counter2 <= amplification2;
				counter3 <= amplification3;
				counter4 <= amplification4;
			END IF;
			
			IF reset_resistance_processing <= '1' THEN
				IF counter0_0 < 2*max_amp THEN 
					counter0_0 <= counter0_0 + 1;
					
					IF counter0_0 <= max_amp THEN
						-- function for ic 1 pot 1 go down
						pot_control
					ELSE
						-- function for ic 1 pot 2 go down
					END IF
				END IF;
				
				IF counter0_0 == 2*max_amp THEN
					counter0_1 <= counter0_1 + 1
					
					IF counter0_1 <= max_amp THEN
						-- function for ic 2 pot 1 go down
					ELSE
						-- function for ic 2 pot 2 go down
					END IF					
					
				END IF;
			END IF;
			
			
			
		END IF;
		-- NO VHDL CODE HERE
	END PROCESS;
	

END;