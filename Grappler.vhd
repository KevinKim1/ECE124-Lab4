-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Grappler IS Port
(
	clk_input, reset, grappler, grappler_en	: IN std_logic;
	grappler_on											: OUT std_logic
);
END ENTITY;
 

 Architecture SM of Grappler is
 
  
 TYPE STATE_NAMES IS (s_open, s_close);  -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


BEGIN 
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= s_open;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (grappler, grappler_en, current_state) 

BEGIN
    CASE current_state IS
         WHEN s_open =>		
				IF(grappler='1' AND grappler_en='1') THEN
					next_state <= s_close;
				ELSE
					next_state <= s_open;
				END IF;

         WHEN s_close =>		
				IF(grappler='0' AND grappler_en='1') THEN
					next_state <= s_open;
				ELSE
					next_state <= s_close;
				END IF;

			WHEN OTHERS =>
            next_state <= s_open;
 		END CASE;
		
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN
    CASE current_state IS
         WHEN s_open =>		
			grappler_on <= '0';
			
         WHEN s_close =>		
			grappler_on <= '1';
				
         WHEN others =>		
 			grappler_on <= '0';

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
