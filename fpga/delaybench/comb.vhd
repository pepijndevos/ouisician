library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity comb is
    generic (
      bl_gain : integer;
      ff_gain : integer;
      fb_gain : integer
    );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      offset  : in unsigned(11 downto 0);
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture behavioral of comb is
  component delay
    PORT
    (
      address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      clock		: IN STD_LOGIC  := '1';
      data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      wren		: IN STD_LOGIC ;
      q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  end component;

  signal address		: STD_LOGIC_VECTOR (11 DOWNTO 0);
  signal data		: STD_LOGIC_VECTOR (15 DOWNTO 0);
  signal wren		: STD_LOGIC ;
  signal q		: STD_LOGIC_VECTOR (15 DOWNTO 0);


begin
  process(clk, rst)
    variable oldsnd : std_logic;
    type state_type is (MIX, WRITE,IDLE);
    variable state : state_type := IDLE;
    variable counter : unsigned(11 downto 0) := x"000";
    variable mixed_input : signed(23 downto 0);
    variable mixed_output : signed(31 downto 0);
  begin
    if rst = '0' then
      state := IDLE;
      counter := x"000";
      address <= x"000";
      data <= x"0000";
    elsif rising_edge(clk) then
      case state is
        when MIX =>
          mixed_input := resize(signed(word)*256 + signed(q)*fb_gain, mixed_input'length);
          mixed_output := resize(mixed_input*bl_gain + signed(q)*256*ff_gain, mixed_output'length);
          resp <= resize(mixed_output/65536, resp'length);
          state := WRITE;
        when WRITE =>
          data <= std_logic_vector(resize(mixed_input/256, resp'length));
          address <= std_logic_vector(counter);
          wren <= '1';
          state := IDLE;
        when IDLE =>
          wren <= '0';
          address <= std_logic_vector(counter-offset);
      end case;
      if oldsnd = '0' and sndclk = '1' then --rising edge
        counter := counter + 1;
        state := MIX;
      end if;
      oldsnd := sndclk;
    end if;
  end process;

  delay_inst : delay PORT MAP (
      address	 => address,
      clock	 => clk,
      data	 => data,
      wren	 => wren,
      q	 => q
    );

end;
