-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx4 is port (
	a_in_4, b_in_4   			: in  std_logic_vector(3 downto 0);	 -- Four bit inputs
	a_gt_b, a_eq_b, a_lt_b 	: out std_logic	  						 -- Single bit comparison outputs for the four bit inputs
);
end Compx4;

architecture four_bit_comparator of Compx4 is

-- 1 bit magnitude comparator
component Compx1 port (
	a_in, b_in   												: in std_logic;   -- Single bit inputs
	a_greater_than_b, a_equal_to_b, a_less_than_b 	: out std_logic   -- Single bit comparison outputs for the single bit inputs
); 
end component Compx1;

-- Comparison outputs for each bit of the four bit inputs
signal bit_3_gt, bit_3_eq, bit_3_lt,  
	    bit_2_gt, bit_2_eq, bit_2_lt,  
		 bit_1_gt, bit_1_eq, bit_1_lt,  
		 bit_0_gt, bit_0_eq, bit_0_lt  : std_logic;

begin

-- Four 1 bit comparator component instances for each of the bits in the four bit inputs
bit_3: Compx1 port map (a_in_4(3), b_in_4(3), bit_3_gt, bit_3_eq, bit_3_lt);
bit_2: Compx1 port map (a_in_4(2), b_in_4(2), bit_2_gt, bit_2_eq, bit_2_lt);
bit_1: Compx1 port map (a_in_4(1), b_in_4(1), bit_1_gt, bit_1_eq, bit_1_lt);
bit_0: Compx1 port map (a_in_4(0), b_in_4(0), bit_0_gt, bit_0_eq, bit_0_lt);

-- Cases where four bit input A is greater than four bit input B
a_gt_b <= bit_3_gt OR (bit_3_eq AND bit_2_gt) OR 
			 (bit_3_eq AND bit_2_eq AND bit_1_gt) OR 
			 (bit_3_eq AND bit_2_eq AND bit_1_eq AND bit_0_gt);

-- Case where four bit input A is equal to four bit input B
a_eq_b <= bit_3_eq AND bit_2_eq AND bit_1_eq AND bit_0_eq;

-- Cases where four bit input A is less than four bit input B
a_lt_b <= bit_3_lt OR (bit_3_eq AND bit_2_lt) OR 
			 (bit_3_eq AND bit_2_eq AND bit_1_lt) OR 
			 (bit_3_eq AND bit_2_eq AND bit_1_eq AND bit_0_lt);
			 
end four_bit_comparator;