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
-29,-3,-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-5,-5,-5,-5,-5,-5,-5,
-5,-5,-5,-5,-5,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-5,-5,-5,-5,-5,-5,-5,
-5,-4,-4,-4,-4,-4,-3,-3,-3,-3,-2,-2,-2,-1,-1,-0,0,0,1,1,2,2,3,4,
4,5,5,6,7,7,8,9,10,10,11,12,13,14,14,15,16,17,18,19,20,21,22,23,
24,25,27,28,29,30,31,32,34,35,36,37,39,40,41,43,44,45,47,48,49,51,52,53,
55,56,58,59,61,62,63,65,66,68,69,71,72,73,75,76,78,79,80,82,83,85,86,87,
89,90,91,93,94,95,96,98,99,100,101,102,104,105,106,107,108,109,110,111,112,113,114,114,
115,116,117,117,118,119,119,120,121,121,122,122,123,123,123,124,124,124,124,125,125,125,125,125,
125,125,125,125,125,124,124,124,124,123,123,123,122,122,121,121,120,119,119,118,117,117,116,115,
114,114,113,112,111,110,109,108,107,106,105,104,102,101,100,99,98,96,95,94,93,91,90,89,
87,86,85,83,82,80,79,78,76,75,73,72,71,69,68,66,65,63,62,61,59,58,56,55,
53,52,51,49,48,47,45,44,43,41,40,39,37,36,35,34,32,31,30,29,28,27,25,24,
23,22,21,20,19,18,17,16,15,14,14,13,12,11,10,10,9,8,7,7,6,5,5,4,
4,3,2,2,1,1,0,0,-0,-1,-1,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-4,-4,-5,
-5,-5,-5,-5,-5,-5,-5,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-6,-5,-5,-5,-5,-5,
-5,-5,-5,-5,-5,-5,-5,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-29
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
35,-1,-3,-6,-9,-13,-16,-18,-18,-16,-12,-6,1,9,16,22,
25,25,22,16,6,-5,-17,-28,-36,-41,-40,-34,-24,-8,9,27,
43,55,61,59,50,33,10,-16,-42,-65,-81,-88,-84,-69,-44,-11,
26,62,93,115,123,116,93,57,11,-40,-90,-132,-159,-169,-157,-124,
-73,-9,61,128,183,219,228,210,162,91,3,-91,-181,-253,-298,-308,
-279,-212,-114,7,135,255,351,410,419,376,281,142,-25,-202,-368,-499,
-577,-587,-522,-384,-183,59,316,557,750,865,879,780,568,255,-130,-548,
-952,-1289,-1507,-1559,-1411,-1041,-447,351,1317,2398,3525,4623,5616,6433,7014,7316,
7316,7014,6433,5616,4623,3525,2398,1317,351,-447,-1041,-1411,-1559,-1507,-1289,-952,
-548,-130,255,568,780,879,865,750,557,316,59,-183,-384,-522,-587,-577,
-499,-368,-202,-25,142,281,376,419,410,351,255,135,7,-114,-212,-279,
-308,-298,-253,-181,-91,3,91,162,210,228,219,183,128,61,-9,-73,
-124,-157,-169,-159,-132,-90,-40,11,57,93,116,123,115,93,62,26,
-11,-44,-69,-84,-88,-81,-65,-42,-16,10,33,50,59,61,55,43,
27,9,-8,-24,-34,-40,-41,-36,-28,-17,-5,6,16,22,25,25,
22,16,9,1,-6,-12,-16,-18,-18,-16,-13,-9,-6,-3,-1,35
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
