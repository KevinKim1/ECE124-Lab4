-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XY_Motion is port (
	clk_input, reset  : in std_logic;  		-- Clock and reset for XY motion controller operations
	motion				: in std_logic;  		-- RAC moving when 1, RAC stopped when 0
	extender_out		: in std_logic;  		-- Extender is NOT retracted (0000) when 1
	X_LT, X_EQ, X_GT  : in std_logic;  		-- Comparison between target XY pos held in registers and current XY pos held in binary counter
	Y_LT, Y_EQ, Y_GT	: in std_logic;  
	
	Capture_XY				: out std_logic;	-- Tells register to capture new XY pos target when 1
	clk_en_x, clk_en_y 	: out std_logic;	-- Rising edge of clock signal triggers binary counter operations
	up_down_x, up_down_y	: out std_logic;	-- Increment/decrement current XY pos depending on comparator outputs
	extender_en				: out std_logic;	-- Tells extender that it is okay to extend from the XY motion controller side when 1
	error						: out std_logic	-- System fault error state
);
end XY_Motion;

architecture one of XY_Motion is

-- Five scenarios that the XY motion controller can be in
type state_names is (s_initial, s_motion_btn_active, s_motion_btn_inactive, s_stop, s_error);		
signal current_state, next_state  : state_names; 				

begin

Register_Section: process (clk_input, reset, next_state)	
begin 
	if (reset = '1') then						-- Reset controller and enter initial state
		current_state <= s_initial;
	
	elsif (rising_edge(clk_input)) then		-- Associate clock signal with controller states
		current_state <= next_state;
	end if;
	
end process;

Transition_Section: process (X_LT, X_EQ, X_GT, Y_LT, Y_EQ, Y_GT, current_state, motion, extender_out)
begin
    case current_state is
	 
         when s_initial =>											-- After reset signal
				if ((X_EQ = '1') AND (Y_EQ = '1')) then		-- Target XY pos is not updated
					next_state <= s_stop;
	
				elsif (motion = '1') then							-- Target XY pos update is initiated
					next_state <= s_motion_btn_active;		
				end if; 
				
			when s_motion_btn_active =>							-- State for updating target XY pos when motion button is pressed
				if ((X_EQ = '0') OR (Y_EQ = '0')) then			-- Target XY pos is updated to initiate movement
					next_state <= s_motion_btn_inactive;
												
				elsif ((X_EQ = '1') AND (Y_EQ = '1')) then	-- If RAC reached target XY pos before motion button is released
					next_state <= s_stop;
				end if; 		
	
			when s_motion_btn_inactive =>							-- State for RAC motion after button is released
				if ((X_EQ = '0') OR (Y_EQ = '0')) then			-- RAC has not reached either X or Y pos, or haven't reached both
					next_state <= s_motion_btn_inactive;
				
				elsif ((X_EQ = '1') AND (Y_EQ = '1')) then	-- Moving RAC reached target XY pos
					next_state <= s_stop;
				end if;	
				
         when s_stop =>																	-- State when RAC reached target XY pos
				if ((X_EQ = '1') AND (Y_EQ = '1') AND (motion = '0')) then  -- RAC idling or extender extending
					next_state <= s_stop;
					
				elsif ((extender_out = '1') AND (motion = '1')) then			-- Motion attempted while extender extending
					next_state <= s_error;
					
				-- Motion attempted after target XY pos is reached and extender is not extending
				elsif ((X_EQ = '1') AND (Y_EQ = '1') AND (extender_out = '0') AND (motion = '1')) then
					next_state <= s_motion_btn_active;
				end if;
				
         when s_error =>	
				if (extender_out = '0') then		-- Extender fully retracted
					next_state <= s_stop;
					
				else										-- Extender is not done retracting 
					next_state <= s_error;
				end if;
			
 	end case;
end process;

Decoder_Section: process (X_LT, X_EQ, X_GT, Y_LT, Y_EQ, Y_GT, current_state, motion, extender_out) 
begin
    case current_state is
	 
         when s_initial =>					-- Initial state after reset
				extender_en <= '0';
				error <= '0';
				Capture_XY <= '0';
				clk_en_x <= '0';
				clk_en_y <= '0';
				up_down_x <= '0';
				up_down_y <= '0';
					
         when s_motion_btn_active =>	-- Enable position register to caputre target, nothing else
				extender_en <= '0';
				error <= '0';
				Capture_XY <= '1';
				clk_en_x <= '0';
				clk_en_y <= '0';
				up_down_x <= '0';
				up_down_y <= '0';
			
			when s_motion_btn_inactive =>	
				-- Let if-else stateents below infer these signal assignments as the default case for this state
				extender_en <= '0';								
				error <= '0';
				Capture_XY <= '0';
				
				if((X_LT = '1') or (X_GT = '1')) then		-- Inform X binary counter accordingly if X target is not met
					clk_en_x <= '1';
					up_down_x <= X_LT;	
				else
					clk_en_x <= '0';
					up_down_x <= '0';
				end if;
				
				if((Y_LT = '1') or (Y_GT = '1')) then		-- Inform Y binary counter accordingly if Y target is not met
					clk_en_y <= '1';
					up_down_y <= Y_LT;
				else
					clk_en_y <= '0';
					up_down_y <= '0';
				end if;
								
         when s_stop =>						-- Enable extender, nothing else
				extender_en <= '1';
				error <= '0';
				clk_en_x <= '0';
				clk_en_y <= '0';
				up_down_x <= '0';
				up_down_y <= '0';
				
         when s_error =>		
				-- Error state only occurs after stop state. Let if-else stateents below infer theis signal assignment 
				-- as the default case for the error state. Also infer any output signals that have no assignment from the stop state.
				extender_en <= '1';
				
				if(extender_out = '0') then	-- Extender fully retracted
					error <= '0';
				else 
					error <= '1';
				end if;
				
	end case;
end process;
end one;
 
 