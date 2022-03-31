-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Extender IS Port
(
	clk_input, reset, extender, extender_en		 : IN std_logic;
	ext_pos												    : IN std_logic_vector(5 downto 2);
	extender_out, grappler_en, clk_en, left_right : OUT std_logic
);
END ENTITY;
 

 Architecture SM of Extender is
 
  
 TYPE STATE_NAMES IS (ret, ext1, ext2, ext3, full_ext);  -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


BEGIN
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= ret;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (extender, extender_en, current_state) 

BEGIN
    CASE current_state IS
         WHEN ret =>
				IF(extender='1' AND extender_en='1') THEN
					next_state <= ext1;
				ELSE
					next_state <= ret;
				END IF;

         WHEN ext1 =>
				IF(extender='1') THEN
					next_state <= ext2;
				ELSE
					next_state <= ret;
				END IF;

         WHEN ext2 =>		
				IF(extender='1') THEN
					next_state <= ext3;
				ELSE
					next_state <= ext1;
				END IF;
				
         WHEN ext3 =>		
				IF(extender='1') THEN
					next_state <= full_ext;
				ELSE
					next_state <= ext2;
				END IF;

         WHEN full_ext =>		
				IF(extender='1') THEN
					next_state <= full_ext;
				ELSE
					next_state <= ext3;
				END IF;

			WHEN OTHERS =>
            next_state <= ret;
 		END CASE;
		
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (current_state) 

BEGIN
    CASE current_state IS
         WHEN ret =>		
			extender_out <= '0';
			grappler_en <= '0';
			IF(extender_en='1') THEN
				clk_en <= '1';
			ELSE
				clk_en <= '0';
			END IF;
			
         WHEN ext1 =>		
			extender_out <= '1';
			grappler_en <= '0';
			IF(extender='1') THEN
				clk_en <= '1';
				left_right <= '1';
			ELSE
				clk_en <= '1';
				left_right <= '0';
			END IF;

         WHEN ext2 =>		
			extender_out <= '1';
			grappler_en <= '0';
			IF(extender='1') THEN
				clk_en <= '1';
				left_right <= '1';
			ELSE
				clk_en <= '1';
				left_right <= '0';
			END IF;
			
         WHEN ext3 =>		
			extender_out <= '1';
			grappler_en <= '0';
			IF(extender='1') THEN
				clk_en <= '1';
				left_right <= '1';
			ELSE
				clk_en <= '1';
				left_right <= '0';
			END IF;

         WHEN full_ext =>		
			extender_out <= '1';
			grappler_en <= '1';
			clk_en <= '0';
			IF(extender_en='1') THEN
				clk_en <= '1';
			ELSE
				clk_en <= '0';
			END IF;
				
         WHEN others =>		
 			extender_out <= '0';
			grappler_en <= '0';
			clk_en <= '0';
			left_right <= '0';
			
	  END CASE;
 END PROCESS;
 

 END ARCHITECTURE SM;
