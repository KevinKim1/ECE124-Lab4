-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx1 is port (
	
	a_in, b_in   												: in std_logic;	-- Single bit inputs
	
	a_greater_than_b, a_equal_to_b, a_less_than_b 	: out std_logic   -- Single bit outputs
);
end Compx1;

architecture one_bit_comparator of Compx1 is

-- Compares magnitude of two single bit inputs and return comparison outputs using boolean equations
begin
 
	a_greater_than_b <= a_in AND (NOT b_in);
	a_equal_to_b	  <= a_in XNOR b_in;
	a_less_than_b 	  <= (NOT a_in) AND b_in;
	
end one_bit_comparator;
 
 