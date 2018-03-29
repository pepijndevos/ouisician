LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY normalization IS
	PORT (clk, reset, key0, key1, key2, key3 : IN std_logic;
			amplification1, amplification2, amplification3, amplification4 : IN integer range 0 to 128;
			led : OUT std_logic;
			ic : OUT std_logic_vector(7 DOWNTO 0)
			);
END ENTITY normalization;

-- up_down, change resistence '0' = down
-- chip_select, allow change restance if '0' = on  
-- mode_select, allow independent change '0' = nonindependent, '1' = independent
-- dacsel, '0' = rdac 1, '1' = rdac 2

--ic = (up_down1, chip_select1, mode_select1, dacsel1, up_down2, chip_select2, mode_select2, dacsel2)

ARCHITECTURE bhv OF normalization IS

	TYPE int_array IS ARRAY (0 to 3) of integer range 0 to 128;

	FUNCTION pot_control (pot_select_ic_1 : std_logic; pot_select_ic_2 : std_logic; des_amp_ic_1 : integer; des_amp_ic_2 : integer; cur_amp_ic_1 : integer; cur_amp_ic_2 : integer) 
				RETURN std_logic_vector IS
		Variable ic_func : std_logic_vector(7 DOWNTO 0);
	BEGIN
		IF pot_select_ic_1 = '0' THEN
			-- ic 1 pot 1
			IF (des_amp_ic_1 - cur_amp_ic_1) = 0 THEN
				ic_func(7 DOWNTO 4) := "1110";
			ELSIF (des_amp_ic_1 - cur_amp_ic_1) > 0 THEN
				ic_func(7 DOWNTO 4) := "1010";
			ELSE
				ic_func(7 DOWNTO 4) := "0010";
			END IF;
		ELSE
			-- ic 1 pot 2
			IF (des_amp_ic_1 - cur_amp_ic_1) = 0 THEN
				ic_func(7 DOWNTO 4) := "1111";
			ELSIF (des_amp_ic_1 - cur_amp_ic_1) > 0 THEN
				ic_func(7 DOWNTO 4) := "1011";
			ELSE
				ic_func(7 DOWNTO 4) := "0011";
			END IF;
		END IF;

		IF pot_select_ic_2 = '0' THEN
			-- ic 2 pot 1
			IF (des_amp_ic_2 - cur_amp_ic_2) = 0 THEN
				ic_func(3 DOWNTO 0) := "1110";
			ELSIF (des_amp_ic_2 - cur_amp_ic_2) > 0 THEN
				ic_func(3 DOWNTO 0) := "1010";
			ELSE
				ic_func(3 DOWNTO 0) := "0010";
			END IF;
		ELSE
			-- ic 2 pot 2
			IF (des_amp_ic_2 - cur_amp_ic_2) = 0 THEN
				ic_func(3 DOWNTO 0) := "1111";
			ELSIF (des_amp_ic_2 - cur_amp_ic_2) > 0 THEN
				ic_func(3 DOWNTO 0) := "1011";
			ELSE
				ic_func(3 DOWNTO 0) := "0011";
			END IF;
		END IF;
		RETURN ic_func;
	END pot_control;
	
	FUNCTION comp (dif1 : integer; dif2 : integer) 
				RETURN std_logic_vector IS
		Variable data : std_logic_vector(1 DOWNTO 0);
		BEGIN
		IF dif1 > 0 THEN
			data(1) := '0';
		ELSE
			data(1) := '1';
		END IF;
		
		IF dif2 > 0 THEN
			data(0) := '0';
		ELSE
			data(0) := '1';
		END IF;		
		RETURN data;
	END comp;	
	
	
		
	FUNCTION hex2display (n:std_logic_vector(3 DOWNTO 0)) 
			RETURN std_logic_vector IS
		VARIABLE res : std_logic_vector(6 DOWNTO 0);
	BEGIN
    CASE n IS          --        gfedcba; low active
	    WHEN "0000" => RETURN NOT "0111111";
	    WHEN "0001" => RETURN NOT "0000110";
	    WHEN "0010" => RETURN NOT "1011011";
	    WHEN "0011" => RETURN NOT "1001111";
	    WHEN "0100" => RETURN NOT "1100110";
	    WHEN "0101" => RETURN NOT "1101101";
	    WHEN "0110" => RETURN NOT "1111101";
	    WHEN "0111" => RETURN NOT "0000111";
	    WHEN "1000" => RETURN NOT "1111111";
	    WHEN "1001" => RETURN NOT "1101111";
	    WHEN "1010" => RETURN NOT "1110111";
	    WHEN "1011" => RETURN NOT "1111100";
	    WHEN "1100" => RETURN NOT "0111001";
	    WHEN "1101" => RETURN NOT "1011110";
	    WHEN "1110" => RETURN NOT "1111001";
	    WHEN OTHERS => RETURN NOT "1110001";			
    END CASE;
  END hex2display;		
		
		
		
		
	SIGNAL counter0_0, counter0_1, counter1, counter2, counter3, counter4 : integer range 0 to 256;
	SIGNAL start_up, reset_resistance_processing : std_logic := '0';
	SIGNAL reset_amp : integer range 0 to 128 := 64; 
	SIGNAL max_amp : integer range 0 to 128 := 128;
	SIGNAL cur_amp, old_des_amp : int_array;
	
	BEGIN
		
	PROCESS(clk, reset, key0, key1, key2, key3)
		VARIABLE temp_data : std_logic_vector(1 DOWNTO 0);
		VARIABLE des_amp,new_des_amp : int_array;
	BEGIN
		-- NO VHDL CODE HERE
		IF reset='0' THEN
		counter0_0 <= 0;
		counter1 <= 0;
		counter2 <= 0;
		counter3 <= 0;
		counter4 <= 0;
		start_up <= '0';
		
		led<='0';
		
		
		ELSIF falling_edge(clk) THEN
			
			IF start_up = '0' THEN 
				start_up <= '1';
				reset_resistance_processing <= '1';
				counter0_0 <= 0;
				counter0_1 <= 0;
			END IF;
			
			IF reset_resistance_processing = '1' THEN
				IF counter0_0 < 2*max_amp THEN 
					counter0_0 <= counter0_0 + 1;
					IF counter0_0 < max_amp THEN
						ic <= pot_control('0', '0', 0, 0, (max_amp - counter0_0), (max_amp - counter0_0));
					ELSE
						ic <= pot_control('1', '1', 0, 0, (2*max_amp - counter0_0), (2*max_amp - counter0_0));
					END IF;
				ELSIF counter0_0 >= 2*max_amp AND  counter0_1 < 2*reset_amp THEN
					counter0_1 <= counter0_1 + 1;					
					IF counter0_1 < reset_amp THEN
						ic<= pot_control('0', '0', reset_amp, reset_amp, counter0_1, counter0_1);
						cur_amp <= (counter0_1,counter0_1,0,0);
					ELSIF counter0_1 >= reset_amp THEN
						ic<= pot_control('1', '1', reset_amp, reset_amp, (counter0_1 - reset_amp), (counter0_1 - reset_amp));
						cur_amp <= (64,64,counter0_1 - reset_amp,counter0_1 - reset_amp);
					END IF;
				
				ELSE
					cur_amp <= (64,64,64,64);
					ic <= pot_control('0', '0', 0, 0, 0, 0);
					des_amp := (amplification1,amplification2,amplification3,amplification4);
					new_des_amp := (amplification1,amplification2,amplification3,amplification4);
					old_des_amp <= new_des_amp;
					reset_resistance_processing <='0';
					counter0_0<= 0;
					counter0_1<= 0;
				END IF;
			END IF;
			
			IF reset_resistance_processing = '0' AND start_up = '1' THEN
			new_des_amp := (amplification1,amplification2,amplification3,amplification4);
			old_des_amp <= new_des_amp;
				IF new_des_amp(0) /= old_des_amp(0) THEN
					des_amp(0) := new_des_amp(0);
				ELSIF  new_des_amp(1) /= old_des_amp(1) THEN	
					des_amp(1) := new_des_amp(1);	
				ELSIF  new_des_amp(2) /= old_des_amp(2) THEN	
					des_amp(2) := new_des_amp(2);						
				ELSIF  new_des_amp(3) /= old_des_amp(3) THEN	
					des_amp(3) := new_des_amp(3);	
				END IF;
	
				IF key0 = '0' AND cur_amp(0) < 128 THEN
					des_amp(0) := des_amp(0) +1;
				ELSIF key1 = '0' AND cur_amp(0) < 128  THEN
					des_amp(0) := des_amp(1) -1;	
				ELSIF key2 = '0' AND cur_amp(2) < 128  THEN
					des_amp(2) := des_amp(2) +1;				
				ELSIF key3 = '0' AND cur_amp(2) < 128  THEN
					des_amp(2) := des_amp(2) -1;				
				END IF;
				
				IF (((cur_amp(0) - des_amp(0)) /= 0) AND ((cur_amp(2) - des_amp(2)) /= 0))THEN 
					temp_data := comp((cur_amp(0) - des_amp(0)), (cur_amp(2) - des_amp(2)));
					ic <= pot_control('0', '0', des_amp(0), des_amp(2), cur_amp(0), cur_amp(2));					
					IF temp_data(1) = '1' THEN
						cur_amp(0) <= cur_amp(0) + 1;
					ELSE
						cur_amp(0) <= cur_amp(0) - 1;
					END IF;
					
					IF temp_data(0) = '1' THEN
						cur_amp(2) <= cur_amp(2) + 1;
					ELSE
						cur_amp(2) <= cur_amp(2) - 1;
					END IF;				

				
				
				ELSIF (((cur_amp(0) - des_amp(0)) /= 0) AND ((cur_amp(2) - des_amp(2)) = 0)) THEN 
					temp_data := comp((cur_amp(0) - des_amp(0)), (cur_amp(2) - des_amp(2)));
					ic <= pot_control('0', '0', des_amp(0), des_amp(2), cur_amp(0), cur_amp(2));					
					IF temp_data(1) = '1' THEN
						cur_amp(0) <= cur_amp(0) + 1;
					ELSE
						cur_amp(0) <= cur_amp(0) - 1;
					END IF;
							
				
				ELSIF (((cur_amp(0) - des_amp(0)) = 0) AND ((cur_amp(2) - des_amp(2)) /= 0))THEN 
					temp_data := comp((cur_amp(0) - des_amp(0)), (cur_amp(2) - des_amp(2)));
					ic <= pot_control('0', '0', des_amp(0), des_amp(2), cur_amp(0), cur_amp(2));										
					IF temp_data(0) = '1' THEN
						cur_amp(2) <= cur_amp(2) + 1;
					ELSE
						cur_amp(2) <= cur_amp(2) - 1;
						END IF;
					END IF;				
				END IF;								
				IF (((cur_amp(0) - des_amp(0)) = 0) AND ((cur_amp(2) - des_amp(2)) = 0)) THEN
					IF (((cur_amp(1) - des_amp(1)) /= 0) AND ((cur_amp(3) - des_amp(3)) /= 0)) THEN 
					temp_data := comp((cur_amp(1) - des_amp(1)), (cur_amp(3) - des_amp(3)));
					ic <= pot_control('1', '1', des_amp(1), des_amp(3), cur_amp(1), cur_amp(3));					
					IF temp_data(1) = '1' THEN
						cur_amp(1) <= cur_amp(1) + 1;
					ELSE
						cur_amp(1) <= cur_amp(1) - 1;
					END IF;
					
					IF temp_data(0) = '1' THEN
						cur_amp(3) <= cur_amp(3) + 1;
					ELSE
						cur_amp(3) <= cur_amp(3) - 1;
					END IF;
					
					ELSIF (((cur_amp(1) - des_amp(1)) /= 0) AND ((cur_amp(3) - des_amp(3)) = 0)) THEN 
					temp_data := comp((cur_amp(1) - des_amp(1)), (cur_amp(3) - des_amp(3)));
					ic <= pot_control('1', '1', des_amp(1), des_amp(3), cur_amp(1), cur_amp(3));					
					IF temp_data(1) = '1' THEN
						cur_amp(1) <= cur_amp(1) + 1;
					ELSE
						cur_amp(1) <= cur_amp(1) - 1;
					END IF;
					
					ELSIF (((cur_amp(1) - des_amp(1)) = 0) AND ((cur_amp(3) - des_amp(3)) /= 0)) THEN 
					temp_data := comp((cur_amp(1) - des_amp(1)), (cur_amp(3) - des_amp(3)));
					ic <= pot_control('1', '1', des_amp(1), des_amp(3), cur_amp(1), cur_amp(3));					
					IF temp_data(0) = '1' THEN
						cur_amp(3) <= cur_amp(3) + 1;
					ELSE
						cur_amp(3) <= cur_amp(3) - 1;
					END IF;			
			
					ELSE
					ic <= pot_control('0', '0', 0, 0, 0, 0);
				END IF;
				END IF;
			END IF;
		-- NO VHDL CODE HERE
	END PROCESS;
	

END;