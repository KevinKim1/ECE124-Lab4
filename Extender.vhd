-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Extender IS Port
(
	clk_input, reset, extender, extender_en		 : IN std_logic;							
	ext_pos												    : IN std_logic_vector(5 downto 2); -- 4bit extender position
	extender_out, grappler_en, clk_en, left_right : OUT std_logic							-- Output enable and extender state/direction indicator
);																												-- signals for shift register and XY motion controller
END ENTITY;
 
 Architecture SM of Extender is
  
 TYPE STATE_NAMES IS (ret, ext1, ext2, ext3, full_ext_stay, full_ext_ret);  
 SIGNAL current_state, next_state	:  STATE_NAMES;     							 
 signal direction : std_logic; 								-- Internal signal to indicate direction of extender motion

BEGIN
 
Register_Section: PROCESS (clk_input, reset, next_state) 
BEGIN
	IF (reset = '1') THEN					-- Reset puts extender into 0000 position
		current_state <= ret;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_state;      -- Synchronize activity to clock signal
	END IF;
END PROCESS;	

Transition_Section: PROCESS (extender, extender_en, current_state, direction) 
BEGIN
    CASE current_state IS	
         WHEN ret =>														-- 0000 position
				IF((extender='1') AND (extender_en='1')) THEN   -- Begin extending
					next_state <= ext1;
				ELSE															-- Remain retracted
					next_state <= ret;
				END IF;

         WHEN ext1 =>					-- 1000 position
				IF(direction='1') THEN
					next_state <= ext2;	-- Continue extending
				ELSE
					next_state <= ret;	-- Continue retracting
				END IF;

         WHEN ext2 =>					-- 1100 position
				IF(direction='1') THEN
					next_state <= ext3;  -- Continue extending
				ELSE
					next_state <= ext1;  -- Continue retracting
				END IF;
				
         WHEN ext3 =>								-- 1110 position
				IF(direction='1') THEN
					next_state <= full_ext_stay;  -- Continue extending
				ELSE
					next_state <= ext2;				-- Continue retracting
				END IF;

         WHEN full_ext_stay =>										-- 1111 position
			
				-- If extender is triggered again, go into full extended state where retraction is intended
				IF((extender_en='1') AND (extender='1')) THEN	
					next_state <= full_ext_ret;
					
				-- If extender not triggered, remain in full extended state where idling in extended mode is intended
				ELSE
					next_state <= full_ext_stay;
				END IF;
						
			WHEN full_ext_ret =>				-- State where extender is still fully extended, but retraction is initiated
				IF(direction='0') THEN 
					next_state <= ext3;		-- Only one direction from this state (retraction to 0000)
				END IF;
			
			WHEN OTHERS =>						
            next_state <= ret;
 		END CASE;
 END PROCESS;

Decoder_Section: PROCESS (current_state, extender, extender_en, direction) 
BEGIN
    CASE current_state IS
         WHEN ret =>		
				-- Let if-else statement below infer these default signal values
				extender_out <= '0';										
				grappler_en <= '0';										-- Only enable grappler when fully extended
				direction <= '1';											-- Direction from retracted state is only towards extension
				
				IF((extender_en='1') AND (extender='1')) THEN	-- If extender is triggered, set outputs to initate extension
					clk_en <= '1';
					left_right <= '1';
				ELSE															-- Do not drive clock signal to remain retracted
					clk_en <= '0';
					left_right <= '0';
				END IF;
				
         WHEN ext1 =>	
				-- Let if-else statement below infer these default signal values
				extender_out <= '1';
				grappler_en <= '0';
				IF(direction='1') THEN		-- Drive clock signal for increment
					clk_en <= '1';
					left_right <= '1';
					direction <= '1';
				ELSE								-- Drive clock signal for decrement 
					clk_en <= '1';
					left_right <= '0';
					direction <= '0';
				END IF;

         WHEN ext2 =>
				-- Let if-else statement below infer these default signal values	
				extender_out <= '1';
				grappler_en <= '0';
				IF(direction='1') THEN	-- Drive clock signal for increment
					clk_en <= '1';
					left_right <= '1';
				ELSE							-- Drive clock signal for decrement
					clk_en <= '1';
					left_right <= '0';
				END IF;
				
         WHEN ext3 =>	
				extender_out <= '1';
				grappler_en <= '0';
				IF(direction='1') THEN	
					clk_en <= '1';
					left_right <= '1';
					direction <= '1';
				ELSE							
					clk_en <= '1';
					left_right <= '0';
					direction <= '0';
				END IF;

         WHEN full_ext_stay =>	
				extender_out <= '1';		
				grappler_en <= '1';		-- Grappler now enabled	
				left_right <= '0';
				clk_en <= '0';  			-- Disable clock to prevent extender motion until extender is triggered again
				direction <= '0';
				
			WHEN full_ext_ret =>
				extender_out <= '1';
				grappler_en <= '1';		-- Grappler still enabled
				left_right <= '0';
				clk_en <= '1';				-- Drive clock signal for decrement
				direction <= '0';
				
         WHEN others =>		
				extender_out <= '0';
				grappler_en <= '0';
				clk_en <= '0';
				left_right <= '0';
				direction <= '0';
	  END CASE;
 END PROCESS;
 END ARCHITECTURE SM;
