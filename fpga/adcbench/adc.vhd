library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;

entity adc is
    generic (
        use_fir : boolean := false
      );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
		sndclk : out std_logic;
      data   : in std_logic;
      word   : out signed(15 downto 0)
    );
end;

architecture behavioral of adc is
  component polyphase
    Generic (
        coef_scale : integer;
        w_acc : integer;
        w_in : integer;
        w_out : integer;
        coef : array_of_integers;
        D : integer := 4
    );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      inclk : in std_logic;
      outclk : out std_logic;
      word   : in signed(w_in-1 downto 0);
      resp   : out signed(w_out-1 downto 0)
    );
  end component;

	signal interclk : std_logic := '0';
	signal input : signed(0 downto 0);
	signal inter : signed(15 downto 0);

begin

using_mean : if not use_fir generate

  process(clk, rst)
    variable buf : std_logic_vector(1023 downto 0);
    variable sum : unsigned(11 downto 0);
    variable data_num : unsigned(0 downto 0);
    variable last_num : unsigned(0 downto 0);
  begin
    if rst = '0' then
      buf := (others => '0');
      sum := to_unsigned(0, sum'length);
    elsif rising_edge(clk) then
      data_num(0) := buf(buf'low);
      last_num(0) := buf(buf'high);
      sum := sum - last_num + data_num;
      word <= resize((signed(resize(sum, word'length)) - x"200")*64, word'length);
      buf := buf(buf'high-1 downto buf'low) & data;
    end if;
  end process;
end generate;

using_fir : if use_fir generate
  process(clk, rst)
    variable buf : std_logic_vector(1023 downto 0);
    variable sum : unsigned(11 downto 0);
    variable data_num : unsigned(0 downto 0);
    variable last_num : unsigned(0 downto 0);
  begin
    if rst = '0' then
      buf := (others => '0');
      sum := to_unsigned(0, sum'length);
    elsif rising_edge(clk) then
	     input(0) <= data;
    end if;
  end process;
  
  filter_inst1 : polyphase
  generic map (
    coef_scale => 1,
    w_acc => 32,
    w_in => 1,
    w_out => 16,
    D => 128,
    coef => (
-29,-4,-5,-6,-5,-2,4,13,24,39,55,72,89,104,115,123,125,122,114,102,87,71,53,37,23,12,4,-2,-5,-6,-5,-4,
-3,-4,-5,-6,-4,-1,5,14,25,40,56,73,90,105,116,123,125,122,114,101,86,69,52,36,22,11,3,-2,-5,-6,-5,-4,
-3,-4,-5,-6,-4,-1,5,14,27,41,58,75,91,106,117,123,125,121,113,100,85,68,51,35,21,10,2,-3,-5,-6,-5,-4,
-3,-4,-5,-6,-4,-0,6,15,28,43,59,76,93,107,117,124,125,121,112,99,83,66,49,34,20,10,2,-3,-5,-6,-5,-4,
-3,-4,-5,-6,-4,0,7,16,29,44,61,78,94,108,118,124,125,120,111,98,82,65,48,32,19,9,1,-3,-5,-6,-5,-3,
-3,-5,-6,-5,-4,0,7,17,30,45,62,79,95,109,119,124,124,119,110,96,80,63,47,31,18,8,1,-3,-5,-6,-5,-3,
-3,-5,-6,-5,-3,1,8,18,31,47,63,80,96,110,119,124,124,119,109,95,79,62,45,30,17,7,0,-4,-5,-6,-5,-3,
-3,-5,-6,-5,-3,1,9,19,32,48,65,82,98,111,120,125,124,118,108,94,78,61,44,29,16,7,0,-4,-6,-5,-4,-3,
-4,-5,-6,-5,-3,2,10,20,34,49,66,83,99,112,121,125,124,117,107,93,76,59,43,28,15,6,-0,-4,-6,-5,-4,-3,
-4,-5,-6,-5,-3,2,10,21,35,51,68,85,100,113,121,125,123,117,106,91,75,58,41,27,14,5,-1,-4,-6,-5,-4,-3,
-4,-5,-6,-5,-2,3,11,22,36,52,69,86,101,114,122,125,123,116,105,90,73,56,40,25,14,5,-1,-4,-6,-5,-4,-3,
-4,-5,-6,-5,-2,4,12,23,37,53,71,87,102,114,122,125,123,115,104,89,72,55,39,24,13,4,-2,-5,-6,-5,-4,-29

	 )
  )
  port map (
    rst => rst,
    clk => clk,
    inclk => clk,
    outclk => interclk,
    word => input,
    resp => inter
  );
  filter_inst2 : polyphase
  generic map (
    coef_scale => 2**16,
    w_acc => 32,
    w_in => 16,
    w_out => 16,
    D => 8,
    coef => (
35,-18,25,-36,43,-42,26,11,-73,162,-279,419,-577,750,-952,1317,7316,351,-548,557,-499,410,-308,210,-124,57,-11,-16,27,-28,22,-18,
-1,-16,25,-41,55,-65,62,-40,-9,91,-212,376,-587,865,-1289,2398,7014,-447,-130,316,-368,351,-298,228,-157,93,-44,10,9,-17,16,-16,
-3,-12,22,-40,61,-81,93,-90,61,3,-114,281,-522,879,-1507,3525,6433,-1041,255,59,-202,255,-253,219,-169,116,-69,33,-8,-5,9,-13,
-6,-6,16,-34,59,-88,115,-132,128,-91,7,142,-384,780,-1559,4623,5616,-1411,568,-183,-25,135,-181,183,-159,123,-84,50,-24,6,1,-9,
-9,1,6,-24,50,-84,123,-159,183,-181,135,-25,-183,568,-1411,5616,4623,-1559,780,-384,142,7,-91,128,-132,115,-88,59,-34,16,-6,-6,
-13,9,-5,-8,33,-69,116,-169,219,-253,255,-202,59,255,-1041,6433,3525,-1507,879,-522,281,-114,3,61,-90,93,-81,61,-40,22,-12,-3,
-16,16,-17,9,10,-44,93,-157,228,-298,351,-368,316,-130,-447,7014,2398,-1289,865,-587,376,-212,91,-9,-40,62,-65,55,-41,25,-16,-1,
-18,22,-28,27,-16,-11,57,-124,210,-308,410,-499,557,-548,351,7316,1317,-952,750,-577,419,-279,162,-73,11,26,-42,43,-36,25,-18,35
)
  )
  port map (
    rst => rst,
    clk => clk,
    inclk => interclk,
    outclk => sndclk,
    word => inter,
    resp => word
  );
end generate;

end;
