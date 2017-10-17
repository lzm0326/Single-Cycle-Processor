-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.0.0 Build 211 04/27/2016 SJ Standard Edition"
-- CREATED		"Fri Mar 31 00:10:07 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY single_cycle_MIPS_Processor IS 
	PORT
	(
		Imem_en :  IN  STD_LOGIC;
		clock :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC
	);
END single_cycle_MIPS_Processor;

ARCHITECTURE bdf_type OF single_cycle_MIPS_Processor IS 

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT op_add
	PORT(		 o_F : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT combine_32bit
	PORT(i_0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT constant_4
	PORT(		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	alu_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	byteena :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	instruction :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jump_address :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_shifted :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PC_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(0 TO 31);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(0 TO 4);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(0 TO 4);


BEGIN 
SYNTHESIZED_WIRE_9 <= "00000000000000000000000000000000";
SYNTHESIZED_WIRE_13 <= "00000";
SYNTHESIZED_WIRE_17 <= "1111";
SYNTHESIZED_WIRE_28 <= "00000";



b2v_inst : pc_reg
PORT MAP(CLK => clock,
		 reset => reset,
		 i_next_PC => SYNTHESIZED_WIRE_0,
		 o_PC => o_PC);


b2v_inst1 : sll_2
PORT MAP(i_to_shift => instruction,
		 o_shifted => o_shifted);


b2v_inst10 : op_add
PORT MAP(		 o_F => SYNTHESIZED_WIRE_26);


b2v_inst11 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_29,
		 o_shifted => SYNTHESIZED_WIRE_27);



b2v_inst123321 : sign_extender_16_32
PORT MAP(i_to_extend => instruction(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_29);


b2v_inst13 : main_control
PORT MAP(i_instruction => instruction,
		 o_reg_dest => SYNTHESIZED_WIRE_5,
		 o_jump => SYNTHESIZED_WIRE_22,
		 o_branch => SYNTHESIZED_WIRE_14,
		 o_mem_to_reg => SYNTHESIZED_WIRE_19,
		 o_mem_write => SYNTHESIZED_WIRE_16,
		 o_ALU_src => SYNTHESIZED_WIRE_6,
		 o_reg_write => SYNTHESIZED_WIRE_2,
		 o_ALU_op => SYNTHESIZED_WIRE_10);


b2v_inst14 : register_file
PORT MAP(CLK => clock,
		 w_en => SYNTHESIZED_WIRE_2,
		 reset => reset,
		 rs_sel => instruction(25 DOWNTO 21),
		 rt_sel => instruction(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_3,
		 w_sel => SYNTHESIZED_WIRE_4,
		 rs_data => SYNTHESIZED_WIRE_11,
		 rt_data => SYNTHESIZED_WIRE_30);


b2v_inst15 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_5,
		 i_0 => instruction(20 DOWNTO 16),
		 i_1 => instruction(15 DOWNTO 11),
		 o_mux => SYNTHESIZED_WIRE_4);



b2v_inst18 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_6,
		 i_0 => SYNTHESIZED_WIRE_30,
		 i_1 => SYNTHESIZED_WIRE_29,
		 o_mux => SYNTHESIZED_WIRE_12);



b2v_inst2 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => clock,
		 wren => Imem_en,
		 address => o_PC(11 DOWNTO 2),
		 byteena => byteena,
		 data => SYNTHESIZED_WIRE_9,
		 q => instruction);


b2v_inst20 : combine_32bit
PORT MAP(i_0 => PC_4(31 DOWNTO 28),
		 i_1 => o_shifted,
		 o_mux => jump_address);


b2v_inst21 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_10,
		 i_A => SYNTHESIZED_WIRE_11,
		 i_B => SYNTHESIZED_WIRE_12,
		 shamt => SYNTHESIZED_WIRE_13,
		 zero => SYNTHESIZED_WIRE_15,
		 ALU_out => alu_out);


b2v_inst22 : and_2
PORT MAP(i_A => SYNTHESIZED_WIRE_14,
		 i_B => SYNTHESIZED_WIRE_15,
		 o_F => SYNTHESIZED_WIRE_24);


b2v_inst23 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => clock,
		 wren => SYNTHESIZED_WIRE_16,
		 address => alu_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_17,
		 data => SYNTHESIZED_WIRE_30,
		 q => SYNTHESIZED_WIRE_20);


b2v_inst24 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_19,
		 i_0 => SYNTHESIZED_WIRE_20,
		 i_1 => alu_out,
		 o_mux => SYNTHESIZED_WIRE_3);


b2v_inst3 : adder_32
PORT MAP(i_A => SYNTHESIZED_WIRE_21,
		 i_B => o_PC,
		 o_F => PC_4);


b2v_inst4 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_22,
		 i_0 => SYNTHESIZED_WIRE_23,
		 i_1 => jump_address,
		 o_mux => SYNTHESIZED_WIRE_0);


b2v_inst5 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_24,
		 i_0 => PC_4,
		 i_1 => SYNTHESIZED_WIRE_25,
		 o_mux => SYNTHESIZED_WIRE_23);


b2v_inst6 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_26,
		 i_A => PC_4,
		 i_B => SYNTHESIZED_WIRE_27,
		 shamt => SYNTHESIZED_WIRE_28,
		 ALU_out => SYNTHESIZED_WIRE_25);



b2v_inst8 : constant_4
PORT MAP(		 o_F => SYNTHESIZED_WIRE_21);



byteena <= "1111";
END bdf_type;