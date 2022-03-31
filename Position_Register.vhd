-- Author: Group 25, Kevin Kim, Jonah Walker
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Position_Register is port 
(	
	input_pos		: in  std_logic_vector(3 downto 0);		-- New XY target position
	CLOCK				: in  std_logic;								-- Clock for register operations
	ENABLE  			: in  std_logic;								-- Register stores new XY target position when 1
	RESET 			: in  std_logic;								-- Register value resets when 1
	output_pos		: out std_logic_vector(3 downto 0)		-- Output target position for comparator
);
end Entity;

architecture one of Position_Register is

signal stored		: std_logic_vector(3 downto 0); 			-- Temporary signal holds new target pos

begin

process(CLOCK, RESET, ENABLE, input_pos) is
begin

	-- Reset stored value
	if(RESET = '1') then			
		stored <= "0000";
	
	-- Store new XY target positon
	elsif (rising_edge(CLOCK) AND (ENABLE ='1')) then
		stored <= input_pos;
	
	end if;
	output_pos <= stored;
	
end process;
end;