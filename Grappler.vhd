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
 
  
 TYPE STATE_NAMES IS (s_open, s_close_btn_active, s_close_btn_inactive);  -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


BEGIN 
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN	-- reset signal
		current_state <= s_open;		-- set back to initial state
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_state;	-- on rising edge, transition to next state
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (grappler, grappler_en, current_state) 

BEGIN
    CASE current_state IS
         WHEN s_open =>		-- initial state - when the grappler is open
				IF(grappler='1' AND grappler_en='1') THEN 	-- grappler is to be toggled and extender is fully extended
					next_state <= s_close_btn_active;			-- close state and button has just been pressed
				ELSE
					next_state <= s_open;							-- stay in same state
				END IF;

         WHEN s_close_btn_active =>								-- grappler is closed and button was just pressed
				IF(grappler='0' AND grappler_en='1') THEN		-- grappler not to be toggled but grappler is still active
					next_state <= s_close_btn_inactive;			-- inactive button state
				ELSIF(grappler='1' AND grappler_en='1') THEN		-- grappler is still receiving input
					next_state <= s_close_btn_active;				-- stay in same state
				ELSE
					next_state <= s_open;								-- open grappler when grappler is no longer enabled
				END IF;
				
			WHEN s_close_btn_inactive =>		
				IF(grappler='0' AND grappler_en='0') THEN			-- grappler to be toggled open
					next_state <= s_open;
				ELSE
					next_state <= s_close_btn_inactive;				-- otherwise stay closed
				END IF;

 		END CASE;
		
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN
    CASE current_state IS
         WHEN s_open =>	
				grappler_on <= '0';				-- grappler is open (0)
			
         WHEN s_close_btn_active =>		
				grappler_on <= '1';				-- grappler is closed (1)
			
			WHEN s_close_btn_inactive =>		
				grappler_on <= '1';				-- grappler is closed (1)

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
