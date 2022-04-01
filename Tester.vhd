-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;


entity Tester is port (
 	MC_TESTMODE				: in  std_logic;							-- Test mode flag
   I1EQI2,I1GTI2,I1LTI2	: in	std_logic;							-- 4bit magnitude comparator comparison results
	input1					: in  std_logic_vector(3 downto 0);	
	input2					: in  std_logic_vector(3 downto 0);
	TEST_PASS  				: out	std_logic							-- Test pass flag
	); 
end Tester;

architecture Test_ckt of Tester is

signal EQ_PASS, GT_PASS, LT_PASS : std_logic;

begin

Tester1: 																			-- Label for identifying process
PROCESS (MC_TESTMODE, input1, input2, I1EQI2, I1GTI2, I1LTI2) is  -- Sensitivity list for process
 
begin																					-- Sequential statements below
		-- When comparison of two inputs matches the result from 4bit magnitude comparator
		IF ((input1 = input2) AND (I1EQI2 = '1')) THEN 
		EQ_PASS <= '1';
		GT_PASS <= '0'; 
		LT_PASS <= '0';
		
		ELSIF ((input1 > input2) AND (I1GTI2 = '1')) THEN  
		GT_PASS <= '1';
		EQ_PASS <= '0'; 
		LT_PASS <= '0';
		
		ELSIF ((input1 < input2) AND (I1LTI2 = '1')) THEN  
		LT_PASS <= '1';
		EQ_PASS <= '0'; 
		GT_PASS <= '0'; 
		-- When comparison of two inputs do not match the result from 4bit magnitude comparator
		ELSE  
		
		EQ_PASS <= '0'; 
		GT_PASS <= '0'; 
		LT_PASS <= '0';
		-- Output the tester result only if the system was in test mode
		END IF;
		TEST_PASS <= MC_TESTMODE AND (EQ_PASS OR GT_PASS OR LT_PASS);
		
end process;

end;