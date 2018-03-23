LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.ALL; 
use ieee.std_logic_signed.all;

entity IIR_Implement is
Generic (
    w_out : integer := 16;
    w_in : integer := 16;
    w_coef: integer:= 20;
	
    B0 : integer := 6 ; -- scaled by 2^16, described by 2^19, 
    B1 : integer := 13 ;
    B2 : integer :=  6;
    A1 : integer := -132892;
    A2 : integer :=  67381 
);
    Port ( iCLK : in STD_LOGIC; --50mhz internal clock
	   sCLK : in STD_LOGIC; --sample clock at 48khz
           Reset : in STD_LOGIC;
           IIR_in : in signed(15 downto 0);
           IIR_out : out signed(15 downto 0)   
);
end IIR_Implement;

architecture behaviour of IIR_Implement is
constant w_mul :integer := w_coef+ w_in;

constant constB0 : signed(w_coef-1 downto 0) := to_signed(B0,w_coef);
constant constB1 : signed(w_coef-1 downto 0) := to_signed(B1,w_coef);
constant constB2 : signed(w_coef-1 downto 0) := to_signed(B2,w_coef);
constant constA1 : signed(w_coef-1 downto 0) := to_signed(A1,w_coef);
constant constA2 : signed(w_coef-1 downto 0) := to_signed(A2,w_coef);

type state_compute is (s1,s2,s3,s4,s5,s6,s7); --make state,clocks at 50Mhz
signal state : state_compute;

signal sum_in : signed(w_in-1 downto 0) := (others=> '0'); --All signals are the same size as multiplication bus,
signal sum_A1A2 : signed(w_in-1 downto 0) := (others => '0');
signal sum_B1B2 : signed(w_in-1 downto 0) := (others=> '0');
signal sum_out : signed(w_in-1 downto 0) := (others => '0');
signal gain_b0 : signed(w_mul-1 downto 0) := (others => '0'); 
signal gain_b1 : signed(w_mul-1 downto 0) := (others => '0'); 
signal gain_b2 : signed(w_mul-1 downto 0) := (others => '0'); 
signal gain_a1 : signed(w_mul-1 downto 0) := (others => '0'); 
signal gain_a2 : signed(w_mul-1 downto 0) := (others => '0'); 
signal Z1 : signed(w_in-1 downto 0) := (others=> '0');
signal Z2 : signed(w_in-1 downto 0) := (others=> '0');
signal x : signed(w_in-1 downto 0) := (others=>'0');
signal y : signed(w_in-1 downto 0) := (others=>'0');
signal done: std_logic := '0';
begin

state_stage : process (iCLK,Reset)
begin
   if(Reset = '0') then
      sum_in <= (others=>'0');
      sum_A1A2 <= (others=>'0');
      sum_B1B2 <= (others=>'0');
      sum_out <= (others=>'0');
      gain_b0 <= (others=>'0');
      gain_b1 <= (others=>'0');
      gain_b2 <= (others=>'0');
      gain_a1 <= (others=>'0');
      gain_a2 <= (others=>'0');
      Z1 <= (others=>'0');
      Z2 <= (others=> '0');
      state <=s1;
   else
      case state is
         when s1 =>
	    done <= '0'; 
	    if(rising_edge(sCLK)) then
	       state <= s2;
	       x <= IIR_in;
	    end if;
         when s2 =>
            gain_a1 <= Z1 * constA1;
	    gain_b1 <= Z1 * constB1;
	    gain_A2 <= Z2 * constA2;
	    gain_B2 <= Z2 * constB2;
	    state <= s3;
         when s3 =>
            sum_A1A2 <= gain_a1(w_mul-1 downto w_coef) + gain_a2(w_mul-1 downto w_coef);
	    sum_B1B2 <= gain_b1(w_mul-1 downto w_coef) + gain_b2(w_mul-1 downto w_coef);
            state <= s4;
         when s4 =>
            sum_in <= x + sum_A1A2;
            state <= s5;
         when s5 =>
	    Z1 <= sum_in;
            Z2 <= Z1;
            gain_b0 <= sum_in * constB0;
            state <= s6;
         when s6 =>
            sum_out <= gain_b0(w_mul-1 downto w_coef) + sum_B1B2;
         when s7 =>
            y <= sum_out;
            done <= '1';
            state <= s1;
            if(rising_edge(sCLK)) and done='1' then 
	       IIR_out <= y;
            end if;
         when others =>
            state <= s1;
	 end case;
   end  if;
end process;
   
end behaviour;