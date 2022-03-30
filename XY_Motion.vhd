-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XY_Motion is port (
	clk_input, reset  : in std_logic;  -- Clock and reset for XY motion controller operations
	motion				: in std_logic;  -- RAC moving when 1, RAC stopped when 0
	extender_out		: in std_logic;  -- Extender is NOT retracted (0000) when 1
	X_LT, X_EQ, X_GT  : in std_logic;  -- Comparison between target XY pos held in registers and current XY pos held in binary counter
	Y_LT, Y_EQ, Y_GT	: in std_logic;  
	
	Capture_XY				: out std_logic;	-- Tells register to capture new XY pos target when 1
	clk_en_x, clk_en_y 	: out std_logic;	-- Rising edge of clock signal triggers binary counter operations
	up_down_x, up_down_y	: out std_logic;	-- Increment/decrement current XY pos depending on comparator outputs
	extender_en				: out std_logic;	-- Tells extender that it is okay to extend from the XY motion controller side when 1
	error						: out std_logic	-- System fault error state
);
end XY_Motion;

architecture one of XY_Motion is

type state_names is (s_initial, s_motion, s_stop, s_error);		-- Four states that the XY motion controller can be in
signal current_state, next_state 	: state_names; 				-- XY motion states

begin

Register_Section: process (clk_input, reset, next_state) is		
begin 
	if (reset = '1') then						-- Reset controller and enter initial state
		current_state <= s_initial;
	elsif (rising_edge(clk_input)) then		-- Associate clock signal with controller states
		current_state <= next_state;
	end if;
end process;

Transition_Section: process (X_LT, X_EQ, X_GT, Y_LT, Y_EQ, Y_GT, current_state, motion, extender_out) 
begin
    case current_state is -- Maps to other states
	 
         when s_initial =>	
			
				-- Motion is triggered, RAC has not reached XY target pos, and extender is not out
				if ((motion = '1') AND ((X_EQ = '0') OR (Y_EQ = '0')) AND (extender_out = '0')) then
					next_state <= s_motion;
					
				-- Motion is stopped, RAC could be or could not be at target pos
				elsif (motion = '0') then
					next_state <= s_stop;
					
				-- No change, remain in initial state
 				else
					next_state <= s_initial;
				end if; 
				
			when s_motion =>
			
				-- Moving RAC reached target XY pos, and extender is not on
				if ((motion = '1') AND (X_EQ = '1') AND (Y_EQ = '1') AND (extender_out = '0')) then
					next_state <= s_stop;
			
				-- Extender is triggered while RAC in motion
				elsif ((motion = '1') AND (extender_out = '1')) then
					next_state <= s_error;
					
				-- No change, remain in motion state
				else
					next_state <= s_motion;
				end if; 					
				
         when s_stop =>
			
				-- Extender is off and motion is on and RAC is not at both target XY pos
				if ((motion = '1') AND ((X_EQ = '0') OR (Y_EQ = '0')) AND (extender_out = '0')) then
					next_state <= s_motion;
					
				-- Extender is extending or motion is off or RAC is at target XY pos
				else
					next_state <= s_stop;
				end if;
		
         when s_error =>	
			
				-- Extender fully retracted
				if (extender_out = '0') then
					next_state <= s_stop;
					
				-- Extender is not done retracting
				else 
					next_state <= s_error;
				end if;
			
			---- DK IF REQURIED?????
			--when others =>
 	end case;
end process;

Decoder_Section: process (X_LT, X_EQ, X_GT, Y_LT, Y_EQ, Y_GT, current_state, motion, extender_out) 
begin
    case current_state is
	 
         when s_initial =>	
			
				-- Initial state after reset
				extender_en <= '0';
				error <= '0';
				
         when s_motion =>		
			
				-- Extender should not be enabled during motion
				extender_en <= '0';
				error <= '0';
				
				-- Clock and up/down control during motion
				if((motion = '1') AND ((X_LT = '1') or (X_GT = '1'))) then
					clk_en_x <= '1';
					up_down_x <= X_LT;
					
				-- Do not send send clock signal to binary counter if not in motion or X target is reached
				else
					clk_en_x <= '0';
				end if;
				
				-- Keep XY separate since if one reaches target pos, the other must be in motion if not yet reached
				if((motion = '1') AND ((Y_LT = '1') or (Y_GT = '1'))) then
					clk_en_y <= '1';
					up_down_y <= Y_LT;
					
				else
					clk_en_y <= '0';
				end if;
				
         when s_stop =>		
			
				-- Do not drive error LED
				error <= '0';
				
				-- DOUBLE CHECK WORK BELOW
				
				-- Motion is initated again
				if(motion = '1') then
					extender_en <= '0';
				
				-- Enable extender and signal register to store new target XY pos
				else
					Capture_XY <= '1';
					extender_en <= '1';
				end if;
				
         when s_error =>		
			
				-- Extender fully retracted
				if(extender_out = '0') then
					error <= '0';
					
				else 
					error <= '1';
				end if;
				
	end case;
end process;

end one;
 
 