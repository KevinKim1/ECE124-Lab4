-- Author: Group 25, Kevin Kim, Jonah Walker
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
	Clk			: in	std_logic;
	pb_n			: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); 
	leds			: out std_logic_vector(7 downto 0);

------------------------------------------------------------------	
	xreg, yreg	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
	xPOS, yPOS	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
------------------------------------------------------------------	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment display (for LogicalStep only)
	seg7_char1  : out	std_logic;				    		-- seg7 digit1 selector (for LogicalStep only)
	seg7_char2  : out	std_logic				    		-- seg7 digit2 selector (for LogicalStep only)
	
	);
END LogicalStep_Lab4_top;

ARCHITECTURE Circuit OF LogicalStep_Lab4_top IS

-- Provided Project Components Used
------------------------------------------------------------------- 
COMPONENT Clock_Source 	port (SIM_FLAG: in boolean;clk_input: in std_logic;clock_out: out std_logic);
END COMPONENT;

--component SevenSegment
--  port 
--   (
--      hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
--      sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
--   ); 
--end component SevenSegment;
--
--component segment7_mux 
--  port 
--   (
--      clk        : in  std_logic := '0';
--		DIN2 		: in  std_logic_vector(6 downto 0);	
--		DIN1 		: in  std_logic_vector(6 downto 0);
--		DOUT			: out	std_logic_vector(6 downto 0);
--		DIG2			: out	std_logic;
--		DIG1			: out	std_logic
--   );
--end component segment7_mux;
------------------------------------------------------------------
-- Add any Other Components here
------------------------------------------------------------------
--component Bidir_shift_reg port 
--(	
--	CLK				: in  std_logic := '0';
--	RESET 			: in  std_logic := '0';
--	CLK_EN			: in  std_logic := '0';
--	LEFT0_RIGHT1	: in  std_logic := '0';
--	REG_BITS			: out std_logic_vector(7 downto 0)
--);
--end component Bidir_shift_reg;
--
--component U_D_Bin_Counter4bit port 
--(	
--	CLK				: in  std_logic := '0';
--	RESET 			: in  std_logic := '0';
--	CLK_EN			: in  std_logic := '0';
--	UP1_DOWN0		: in  std_logic := '0';
--	COUNTER_BITS	: out std_logic_vector(7 downto 0)
--);
--end component U_D_Bin_Counter4bit;

component Counter4 is port 
(	
	CLK				: in  std_logic := '0';
	RESET 			: in  std_logic := '0';
	CLK_EN			: in  std_logic := '0';
	UP1_DOWN0		: in  std_logic := '0';
	COUNTER_BITS	: out std_logic_vector(3 downto 0)
);
end component Counter4;

component Inverter port 
(
	in_1, in_2, in_3, in_4   		: in std_logic;
	out_1, out_2, out_3, out_4 	: out std_logic   
);
end component Inverter;

component XY_Motion is port (
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
end component XY_Motion;

component Position_Register port 
(	
	input_pos		: in  std_logic_vector(3 downto 0);		
	CLOCK				: in  std_logic;								
	ENABLE  			: in  std_logic;								
	RESET 			: in  std_logic;								
	output_pos		: out std_logic_vector(3 downto 0)		
);
end component Position_Register;

component Compx4 port
(
	a_in_4, b_in_4   			: in  std_logic_vector(3 downto 0);	 
	a_gt_b, a_eq_b, a_lt_b 	: out std_logic	  						
);
end component Compx4;

component Extender port
(
	clk_input, reset, extender, extender_en		 : IN std_logic;
	ext_pos												    : IN std_logic_vector(5 downto 2);
	extender_out, grappler_en, clk_en, left_right : OUT std_logic
);
end component Extender;

component Extender_shift port
(	
	clk				: in  std_logic;
	reset 			: in  std_logic;
	clk_en			: in  std_logic;
	left_right	   : in  std_logic;
	ext_pos			: out std_logic_vector(5 downto 2)
);
END component Extender_shift;

component Grappler port
(
	clk_input, reset, grappler, grappler_en	: IN std_logic;
	grappler_on											: OUT std_logic
);
END component Grappler;

------------------------------------------------------------------
-- provided signals
------------------------------------------------------------------
------------------------------------------------------------------	
constant SIM_FLAG : boolean := TRUE; -- set to FALSE when compiling for FPGA download to LogicalStep board
------------------------------------------------------------------	
------------------------------------------------------------------	
-- Create any additional internal signals to be used
signal clk_in, clock						  		: std_logic; 							-- Internal clock
signal RESET, motion,
		 extender_press, grappler_press 		: std_logic; 							-- RAC modes
signal X_target, Y_target 					  	: std_logic_vector(3 downto 0);	-- New target XY positions
signal XLT, XEQ, XGT, YLT, YEQ, YGT		  	: std_logic;								-- XY position comparison outputs
signal reg_en, ext_en, grap_en			  	: std_logic;								-- Enable signal for position registers, extender, and grappler
signal clk_x, clk_y							  	: std_logic;								-- Clock signal for binary counters
signal x_up_down, y_up_down				  	: std_logic;								-- Increment or decrement signal for binary counters

signal X_pos, Y_pos		: std_logic_vector(3 downto 0); 	-- Current XY position output from binary counters
signal X_reg, Y_reg		: std_logic_vector(3 downto 0);  -- Updated XY position output from position registers
signal extender_pos		: std_logic_vector(3 downto 0); 	-- Indicator for extender's position
signal clock_ext			: std_logic;							-- Clock signal for extender position shift register
signal LR					: std_logic; 						 	-- Shift direction indicator
signal ext_out				: std_logic; 							-- Indicator for retracted extender
	
BEGIN
clk_in <= clk;
xreg <= X_reg;
yreg <= Y_reg;

-- XY target position inputs to position storing registers
X_target <= sw(7 downto 4);
Y_target <= sw(3 downto 0);

-- Simulation outputs for current XY position output from binary counters
xPOS <= X_pos;
yPOS <= Y_pos;

-- Display 4 bit extender position to LED
leds(5 downto 2) <= extender_pos;

Clock_Selector: Clock_source port map(SIM_FLAG, clk_in, clock);

-- Invert RAC mode pins
Inverter_Block: Inverter port map(pb_n(3), pb_n(2), pb_n(1),  pb_n(0),
											 RESET,   motion,  extender_press, grappler_press);

-- Instance of XY motion controller
XY_Controller: XY_Motion port map( clock, RESET, motion, ext_out,
											  XLT, XEQ, XGT, YLT, YEQ, YGT,
											  reg_en, clk_x, clk_y, 
											  x_up_down, y_up_down,
											  ext_en, leds(0));

-- Increment/decrement current XY positions depending on comparison results with target position							  
X_UD_Counter: Counter4 port map(clock, RESET, clk_x, x_up_down, X_pos);
Y_UD_Counter: Counter4 port map(clock, RESET, clk_y, y_up_down, Y_pos);
											  
-- Compare target XY position with current XY position
X_Comparator: Compx4 port map(X_pos, X_reg, XGT, XEQ, XLT);
Y_Comparator: Compx4 port map(Y_pos, Y_reg, YGT, YEQ, YLT);

-- For storing and updating target XY position
X_Target_Position: Position_Register port map(X_target, clock, reg_en, RESET, X_reg);
Y_Target_Position: Position_Register port map(Y_target, clock, reg_en, RESET, Y_reg);

-- Instance of Extender
Extender_inst: Extender port map(clock, RESET, extender_press, ext_en, extender_pos,
											ext_out, grap_en, clock_ext, LR);

-- Bidir shift register to show status of extender
Extender_Shift_Register: Extender_shift port map(clock, RESET, clock_ext, LR, extender_pos);

-- Instance of Grappler
Grappler_inst: Grappler port map(clock, RESET, grappler_press, grap_en, leds(1));

END Circuit;
