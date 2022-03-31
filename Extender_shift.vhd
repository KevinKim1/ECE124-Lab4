-- Author: Group 25, Kevin Kim, Jonah Walker
-- BIDIRECTIONAL SHIFT REGISTER
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Extender_shift is port 
(	
	clk				: in  std_logic;
	reset 			: in  std_logic;
	clk_en			: in  std_logic;
	left_right	   : in  std_logic;
	ext_pos			: out std_logic_vector(5 downto 2)
);
end Entity;

ARCHITECTURE one OF Extender_shift IS

Signal sreg			: std_logic_vector(5 downto 2);

BEGIN

process (clk, reset) is
begin
	if (reset = '1') then
				sreg <= "0000";
				
	elsif (rising_edge(clk) AND (clk_en = '1')) then
		
			if (left_right = '1') then  -- TRUE for RIGHT shift
				sreg (3 downto 0) <= '1' & sreg(3 downto 1);  --right-shift of bits
			
			elsif (left_right = '0') then
				sreg (3 downto 0) <= sreg(2 downto 0) & '0';  --left-shift of bits
			
			end if;
	
	end if;
	ext_pos <= sreg;

end process;
END one;
				