-- Author: Group 25, Kevin Kim, Jonah Walker
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Grappler is port
(
	clk_input, reset, 						
	grappler, 									-- Grappler button 
	grappler_en			: in std_logic;	-- Grappler enable signal from XY motion controller
	grappler_on			: out std_logic	-- Output signal is 1 when grappler is closed
);
end entity;
 
architecture one of Grappler is
  
type state_names is (s_closed_btn_active, 	--
							s_closed_btn_inactive,  --
							s_opened_btn_active,    --
							s_opened_btn_inactive); --
							
signal current_state, next_state					: state_names;

begin 
Register_Section: process (clk_input, reset, next_state)  
begin
	if (reset = '1') then 						
		current_state <= s_opened_btn_inactive;	-- Reset causes grappler to open since extender is reset to 0000
	
	elsif(rising_edge(clk_input)) then				-- Synchronize activity to clock signal
		current_state <= next_state;
	end if;
end process;	

Transition_Section: process (grappler, grappler_en, current_state) 
begin
    case current_state is
         when s_opened_btn_inactive =>							
				if (grappler='1' AND grappler_en='1') then		-- Grappler is triggered
					next_state <= s_opened_btn_active;
				else
					next_state <= s_opened_btn_inactive;			-- Grappler is not triggered
				end if;

         when s_opened_btn_active =>								
				if (grappler='0' AND grappler_en='1') then		-- Grappler button is released and grappler closes
					next_state <= s_closed_btn_inactive;
					
				elsif (grappler='1' AND grappler_en='1') then	-- Grappler button is still pressed/held 
					next_state <= s_opened_btn_active;
				end if;
				
			when s_closed_btn_inactive =>			
				if ((grappler = '1') AND (grappler_en='1')) then		-- Grappler is triggered again
					next_state <= s_closed_btn_active;								
				else
					next_state <= s_closed_btn_inactive;					-- Grappler is idle in closed state
				end if;
				
			when s_closed_btn_active =>
				if ((grappler = '0') AND (grappler_en='1')) then	
					next_state <= s_opened_btn_inactive;					-- Grappler button is released and grappler opens
				else
					next_state <= s_closed_btn_active;						-- Grappler button is still pressed/held
				end if;
	end case;
end process;

Decoder_Section: process (current_state, grappler, grappler_en) 
begin
	case current_state is
         when s_opened_btn_inactive =>		
				grappler_on <= '0';
			
         when s_opened_btn_active =>		
				grappler_on <= '1';
				
			when s_closed_btn_inactive =>		
				grappler_on <= '1';
				
			WHEN s_closed_btn_active =>		
				grappler_on <= '0';
	end case;
end process;
end architecture one;