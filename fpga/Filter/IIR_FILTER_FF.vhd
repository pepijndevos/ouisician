----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.03.2018 11:10:25
-- Design Name: 
-- Module Name: IIR_Filter
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

--LPF specs:
--2nd Order Butterworth
--Cut off at 150Hz
--Coefficient scaled by 2^19

entity IIR_FILTER_FF is
Generic (
    w_out : integer := 16;
    w_in : integer := 16;
    w_coef: integer:= 21;

	
    B0 : integer := 51 ; -- scaled by 2^19 
    B1 : integer := -102;
    B2 : integer := 51;
    A1 : integer := 539050;
    A2 : integer := -1063133
);
    Port ( CLK : in STD_LOGIC;
           Reset : in STD_LOGIC;
           IIR_in : in SIGNED(15 downto 0);
           IIR_out : out SIGNED(15 downto 0);
	   Done :out STD_LOGIC	   
);
end IIR_FILTER_FF;

architecture behaviour of IIR_FILTER_FF is
constant w_mul :integer := w_coef+ w_in;

constant constB0 : signed(w_coef-1 downto 0) := to_signed(B0,w_coef);
constant constB1 : signed(w_coef-1 downto 0) := to_signed(B1,w_coef);
constant constB2 : signed(w_coef-1 downto 0) := to_signed(B2,w_coef);
constant constA1 : signed(w_coef-1 downto 0) := to_signed(A1,w_coef);
constant constA2 : signed(w_coef-1 downto 0) := to_signed(A2,w_coef);

-- Registers after the multiplication
signal reg_b0_D,reg_b0_Q : signed(w_mul-1 downto 0) := (others=>'0');
signal reg_b1_D,reg_b1_Q : signed(w_mul-1 downto 0) := (others=>'0');
signal reg_b2_D,reg_b2_Q : signed(w_mul-1 downto 0) := (others=>'0');
signal reg_a1_D,reg_a1_Q : signed(w_mul-1 downto 0) := (others=>'0');
signal reg_a2_D,reg_a2_Q : signed(w_mul-1 downto 0) := (others =>'0');

-- Pipelining registers 
signal reg_sumX_D,reg_sumX_Q : signed (w_in-1 downto 0) := (others =>'0'); --summer at input x and sumA1A2
signal reg_sumA1A2_D,reg_sumA1A2_Q : signed (w_in-1 downto 0) := (others =>'0'); -- summer at a1 a2 coefficient
signal reg_sumB1B2_D,reg_sumB1B2_Q  : signed (w_in-1 downto 0) := (others =>'0'); -- summer at b1 b2 coeff
signal reg_sumY_D,reg_sumY_Q : signed(w_in-1 downto 0):=(others=>'0'); -- summer at output
signal reg_z1_D,reg_z1_Q :signed (w_in-1 downto 0) := (others =>'0'); --flip flop delay 1 
signal reg_z2_D,reg_z2_Q : signed (w_in-1 downto 0) := (others =>'0'); --flip flop delay 2
--
begin





FF : process(CLK) --flip flop generation
begin
if rising_edge(CLK) then
reg_b0_D <= reg_sumX_Q * constB0;
reg_b1_D <= reg_Z1_Q * constB1;
reg_b2_D <= reg_Z2_Q * constB2;
reg_a1_D <= reg_z1_Q * constA1;
reg_a2_D <= reg_z2_Q * constA2;
reg_sumA1A2_D <= reg_a1_Q(w_mul-1 downto w_coef) + reg_a2_Q(w_mul-1 downto w_coef);
reg_sumX_D <=  IIR_in + reg_sumA1A2_Q;
reg_sumB1B2_D <= reg_b1_Q(w_mul-1 downto w_coef) + reg_b2_Q(w_mul-1 downto w_coef);
reg_sumY_D <= reg_b0_Q(w_mul-1 downto w_coef) + reg_sumB1B2_Q;
reg_z1_D <= reg_sumX_Q;
reg_z2_D <= reg_z1_Q;
IIR_out <= reg_sumY_Q;
	if Reset = '0' then
		reg_b0_D <= (others=>'0');
		reg_b1_D <= (others=>'0');
		reg_b2_D <= (others=>'0');
		reg_a1_D <= (others=>'0');
		reg_a2_D <= (others=>'0');
		reg_sumA1A2_D <= (others=>'0');
		reg_sumX_D <= (others=>'0');
		reg_sumB1B2_D <= (others=>'0');
		reg_sumY_D <= (others=>'0');
		reg_z1_D <= (others=>'0');
		reg_z2_D <=(others=>'0');
	else
		reg_b0_D <= reg_b0_Q;
		reg_b1_D <= reg_b1_Q;
		reg_b2_D <= reg_b2_Q;
		reg_a1_D <= reg_a1_Q;
		reg_a2_D <= reg_a2_Q;
		reg_sumA1A2_D <= reg_sumA1A2_Q;
		reg_sumX_D <= reg_sumX_Q;
		reg_sumB1B2_D <= reg_sumB1B2_Q;
		reg_sumY_D <= reg_sumY_Q;
		reg_z1_D <= reg_z1_Q;
		reg_z2_D <=reg_z2_Q;
	end if;
end if;
end process FF;
end behaviour;