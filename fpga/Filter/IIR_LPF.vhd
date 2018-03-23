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

entity IIR_LPF is
Generic (
    output_width : integer := 16;
    input_width : integer := 16;
    B0 : integer := 51 ; -- scaled by 2^19 
    B1 : integer := -102;
    B2 : integer := 51;
    A1 : integer := 539050;
    A2 : integer := -1063133
);
    Port ( CLK : in STD_LOGIC;
           Reset : in STD_LOGIC;
           IIR_in : in signed(15 downto 0);
           IIR_out : out signed(15 downto 0)
);
end IIR_LPF;

architecture behaviour of IIR_LPF is

constant constB0 : signed(18 downto 0) := to_signed(B0,19);
constant constB1 : signed(18 downto 0) := to_signed(B1,19);
constant constB2 : signed(18 downto 0) := to_signed(B2,19);
constant constA1 : signed(18 downto 0) := to_signed(A1,19);
constant constA2 : signed(18 downto 0) := to_signed(A2,19);

signal sum_in : signed(input_width-1 downto 0) := (others=> '0');
signal sum_A1A2 : signed(input_width-1 downto 0) := (others => '0');
signal sum_B1B2 : signed(input_width-1 downto 0) := (others=> '0');
signal sum_out : signed(input_width-1 downto 0) := (others => '0');
signal gain_b0 : signed(input_width+18 downto 0) := (others => '0'); --multiplication of constant with 19 bits
signal gain_b1 : signed(input_width+18 downto 0) := (others => '0'); 
signal gain_b2 : signed(input_width+18 downto 0) := (others => '0'); 
signal gain_a1 : signed(input_width+18 downto 0) := (others => '0'); 
signal gain_a2 : signed(input_width+18 downto 0) := (others => '0'); 
signal Z1 : signed(input_width-1 downto 0) := (others=> '0');
signal Z2 : signed(input_width-1 downto 0) := (others=> '0');
signal x : signed(input_width-1 downto 0) := (others=>'0');
signal y : signed(input_width-1 downto 0) := (others=>'0');

begin


process(CLK,Reset) is
begin
if rising_edge(CLK) then
	    	if (Reset = '0') then
            		sum_in <= (others=>'0');
            		sum_A1A2 <=(others=>'0');
           		sum_B1B2 <=(others=>'0');
            		sum_out <= (others=>'0');
            		gain_b0 <= (others=>'0');
            		gain_b1 <= (others=>'0');
            		gain_b2 <= (others=>'0');
            		gain_a1 <= (others=>'0');
            		gain_a2 <= (others=>'0');
            		Z1 <= (others=>'0');
            		Z2 <= (others=>'0');
            		IIR_out <= (others=>'0');
		else
			Z1 <= sum_in;
            		Z2 <= Z1;
	    		IIR_out <= sum_out;
			gain_b0 <=  constB0 * sum_in;
			gain_b1 <= constB1 * Z1;
			gain_b2 <= constB2 * Z2;
			gain_a1 <= constA1 * Z1;
			gain_a2 <= constA2 * Z2;  
			sum_in <= IIR_in + sum_A1A2;
			sum_A1A2 <= gain_a1(input_width+18 downto 19) + gain_a2(input_width+18 downto 19);
			sum_B1B2 <= gain_b1(input_width+18 downto 19) + gain_b2(input_width+18 downto 19);
			sum_out <= gain_b0(input_width+18 downto 19) + sum_B1B2;
		end if;
	end if;
end process;
end behaviour;

