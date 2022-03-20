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
component Bidir_shift_reg port 
(	
	CLK				: in  std_logic := '0';
	RESET 			: in  std_logic := '0';
	CLK_EN			: in  std_logic := '0';
	LEFT0_RIGHT1	: in  std_logic := '0';
	REG_BITS			: out std_logic_vector(7 downto 0)
);
end component Bidir_shift_reg;

component U_D_Bin_Counter4bit port 
(	
	CLK				: in  std_logic := '0';
	RESET 			: in  std_logic := '0';
	CLK_EN			: in  std_logic := '0';
	UP1_DOWN0		: in  std_logic := '0';
	COUNTER_BITS	: out std_logic_vector(7 downto 0)
);
end component U_D_Bin_Counter4bit;

component Inverter port 
(
	in_1, in_2, in_3, in_4   		: in std_logic;	-- Single bit inputs
	out_1, out_2, out_3, out_4 	: out std_logic   -- Inverted single bit outputs
);
end Inverter;

------------------------------------------------------------------
-- provided signals
------------------------------------------------------------------
------------------------------------------------------------------	
constant SIM_FLAG : boolean := TRUE; -- set to FALSE when compiling for FPGA download to LogicalStep board
------------------------------------------------------------------	
------------------------------------------------------------------	
-- Create any additional internal signals to be used
signal clk_in, clock	: std_logic;


	
BEGIN
clk_in <= clk;

Clock_Selector: Clock_source port map(SIM_FLAG, clk_in, clock);

Inverter_Block: Inverter port map(pb_n(3), pb_n(2), pb_n(1),  pb_n(0),
											 RESET,   motion,  extender, grappler);


Shift_Register: Bidir_shift_reg port map(clock, NOT(pb_n(0)), sw(0), sw(1), leds(7 downto 0));
UD_Counter:		 U_D_Bin_Counter4bit port map(clock, NOT(pb_n(0)), sw(0), sw(1), leds(7 downto 0));

END Circuit;
