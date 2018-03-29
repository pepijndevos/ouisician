library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;

entity polyphase is
Generic (
    coef_scale : integer := 2;
    w_acc : integer := 48;

    coef : array_of_integers := (1, -2, 1, 1, 2, 3, -4, -1);
    D : integer := 2
);
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      inclk : in std_logic;
      outclk : out std_logic;
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
end;

architecture behavioral of polyphase is
  component fir is
    Generic (
        coef_scale : integer;
        w_acc : integer;
        coef : array_of_integers
    );
    port (
      rst    : in std_logic;
      clk    : in std_logic;
      sndclk : in std_logic;
      word   : in signed(15 downto 0);
      resp   : out signed(15 downto 0)
    );
  end component;

  function phase(offset : integer) return array_of_integers is
    variable phase_coef : array_of_integers(0 to coef'length/D-1);
  begin
    for i in 0 to coef'length/D-1 loop
      phase_coef(i) := coef(coef'low + offset + i*D);
    end loop;
    return phase_coef;
  end phase;

  type buf_type is array (0 to D-1) of signed(15 downto 0);
  signal inbuf : buf_type;
  signal outbuf : buf_type;
  signal genclk : std_logic;
begin
  outclk <= genclk;

  process(clk, rst)
  begin
    if rst = '0' then
    elsif rising_edge(clk) then
    end if;
  end process;

gen_fir:
for i in 0 to D-1 generate
  fir_inst: fir
    generic map (
      coef_scale => coef_scale,
      w_acc => w_acc,
      coef => phase(i)
    )
    port map (
      rst => rst,
      clk => clk,
      sndclk => genclk,
      word => inbuf(i),
      resp => outbuf(i)
    );
  end generate gen_fir;
end;
