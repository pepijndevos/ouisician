library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.NUMERIC_STD.ALL;
use work.data_types.all;

entity polyphase is
Generic (
    coef_scale : integer := 1024;
    w_acc : integer := 32;
    coef : array_of_integers :=
(1, -5, -17, -24, 3, 83, 194, 277, 277, 194, 83, 3, -24, -17, -5, 1);
    D : integer := 4
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

  process(inclk, rst)
    variable counter : integer range 0 to D+1;
    variable acc : signed(w_acc-1 downto 0);
  begin
    if rst = '0' then
      counter := 0;
    elsif rising_edge(inclk) then
      inbuf <= word & inbuf(0 to D-2);
      if counter = D then
        -- sum output
        acc := to_signed(0, acc'length);
        for i in outbuf'range loop
          acc := acc + outbuf(i);
        end loop;
        resp <= resize(acc, resp'length);

        genclk <= '1';
        counter := 0;
      else
        genclk <= '0';
        counter := counter + 1;
      end if;
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
