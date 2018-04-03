library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity Echo_FX is
Generic(
 g : integer := 1;
 d : integer := 1--should be multiples of 128 delays
);
port (
	CLK : in std_logic;
	data_in : in signed(15 downto 0);
	data_out : out signed(15 downto 0);
	newValue : in std_logic;
	Echo_EN : in std_logic; --enable
	Reset : in std_logic
);
end;

architecture arch of Echo_FX is
component ShiftReg is
	PORT
	(
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC ;
		shiftin		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		shiftout		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
end component;
signal data_sum : signed(15 downto 0) := (others=>'0');
signal shiftin : std_logic_vector(15 downto 0):= (others =>'0');
signal shiftout: std_logic_vector(15 downto 0) := (others =>'0');
--type shiftin_signals is array(d downto 0) of std_logic_vector(15 downto 0);
--signal shiftin : shiftin_signals;

begin

Delay : ShiftReg
port map
	(
		clken	=>	 newValue,
		clock	=>	CLK,
		shiftin	=>	shiftin,
		shiftout	=> shiftout
	);


process(CLK,Reset) is 

begin
	if (Reset = '0') then
		data_out <= (others=>'0');
--reset to 0 for shift registers
	elsif (rising_edge(CLK)) then
		if(newValue ='1') then
			if (Echo_EN = '1') then
				shiftin <= std_logic_vector(data_sum);
				data_sum	<= shift_right(signed(shiftout),g) + data_in;	
				data_out <= data_sum;
			elsif(Echo_EN = '0') then
				data_out <= data_in;
			end if;
		end if; 
	end if;
end process;

end;