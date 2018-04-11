library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;

entity comb is
    port (
      bl_gain : integer range 0 to 255;
      ff_gain1 : integer range 0 to 255;
      fb_gain1 : integer range 0 to 255;
      ff_gain2 : integer range 0 to 255;
      fb_gain2 : integer range 0 to 255;
      ff_gain3 : integer range 0 to 255;
      fb_gain3 : integer range 0 to 255;
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      offset1  : in unsigned(19 downto 0);
      offset2  : in unsigned(19 downto 0);
      offset3  : in unsigned(19 downto 0);
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture behavioral of comb is

  function interpolate(
  x1 : signed(15 downto 0);
  x2 : signed(15 downto 0);
  p : unsigned(3 downto 0))
  return signed is
    variable sum : signed(19 downto 0);
  begin
    sum := resize(x2*to_integer(p) + x1*(16-to_integer(p)), sum'length);
    return resize(sum/16, 16);
  end interpolate;
  
  component delay
    PORT
    (
      address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      clock		: IN STD_LOGIC  := '1';
      data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      wren		: IN STD_LOGIC ;
      q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  end component;

  signal address		: STD_LOGIC_VECTOR (15 DOWNTO 0);
  signal data		: STD_LOGIC_VECTOR (15 DOWNTO 0);
  signal wren		: STD_LOGIC ;
  signal q		: STD_LOGIC_VECTOR (15 DOWNTO 0);


begin
  process(clk, rst)
    variable oldsnd : std_logic;
    variable state : unsigned(3 downto 0);
    variable counter : unsigned(15 downto 0) := x"0000";
    variable mixed_input : signed(23 downto 0);
    variable mixed_output : signed(31 downto 0);
    variable temp : signed(15 downto 0);
    variable temp2 :signed(15 downto 0);
  begin
    if rst = '0' then
      state := x"0";
      counter := x"0000";
      address <= x"0000";
      data <= x"0000";
    elsif rising_edge(clk) then
      case state is
        when x"0" =>
          address <= std_logic_vector(counter-offset1(19 downto 4));
          state := state + 1;
        when x"1" =>
          address <= std_logic_vector(counter-offset1(19 downto 4)-1);
          state := state + 1;
        when x"2" =>
          address <= std_logic_vector(counter-offset2(19 downto 4));
          state := state + 1;
        when x"3" =>
          address <= std_logic_vector(counter-offset2(19 downto 4)-1);
          -- read offset1
          temp := signed(q);
          state := state + 1;
        when x"4" =>
          address <= std_logic_vector(counter-offset3(19 downto 4));
          -- read offset1+1
          temp2 := interpolate(temp, signed(q), unsigned(offset1(3 downto 0)));
          mixed_input := resize(temp2*fb_gain1, mixed_input'length);
          mixed_output := resize(temp2*ff_gain1, mixed_output'length);
          state := state + 1;
        when x"5" =>
          address <= std_logic_vector(counter-offset3(19 downto 4)-1);
          -- read offset2
          temp := signed(q);
          state := state + 1;
        when x"6" =>
          -- read offset2+1
          temp2 := interpolate(temp, signed(q), unsigned(offset2(3 downto 0)));
          mixed_input := mixed_input + resize(temp2*fb_gain2, mixed_input'length);
          mixed_output := mixed_output + resize(temp2*ff_gain2, mixed_output'length);
          state := state + 1;
        when x"7" =>
          address <= std_logic_vector(counter-offset3(19 downto 4)-1);
          -- read offset3
          temp := signed(q);
          state := state + 1;
        when x"8" =>
          -- read offset3+1
          temp2 := interpolate(temp, signed(q), unsigned(offset3(3 downto 0)));
          mixed_input := mixed_input + resize(temp2*fb_gain3, mixed_input'length);
          mixed_output := mixed_output + resize(temp2*ff_gain3, mixed_output'length);
          state := state + 1;
        when x"9" =>
          mixed_input := mixed_input + resize(signed(word)*256, mixed_input'length);
          mixed_output := resize(mixed_output*256 + mixed_input*bl_gain, mixed_output'length);
          resp <= resize(mixed_output/65536, resp'length);
          data <= std_logic_vector(resize(mixed_input/256, resp'length));
          address <= std_logic_vector(counter);
          wren <= '1';
          state := state + 1;
        when others =>
          wren <= '0';
      end case;
      if oldsnd = '0' and sndclk = '1' then --rising edge
        counter := counter + 1;
        state := x"0";
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
