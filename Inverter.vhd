-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inverter is port (

	in_1, in_2, in_3, in_4   		: in std_logic;	-- Single bit inputs
	out_1, out_2, out_3, out_4 	: out std_logic   -- Inverted single bit outputs
);
end Inverter;

architecture inverter_logic of Inverter is

-- Inverts input signals
begin

	out_1 <= NOT in_1;
	out_2 <= NOT in_2;
	out_3 <= NOT in_3;
	out_4 <= NOT in_4;
	
end inverter_logic;
 