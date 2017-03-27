--Description ===================================================================
--   Self verifying Modular testbench for the Limited.
--Information ===================================================================
--   File name:      TB_Limited.VHDL
--   Target file:	   Limited.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:	VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.0        | Major.minor.patch
--   Created:        13-10-2016
--   Modified:       27-03-2017   | Base functionality validted in testbench
--===============================================================================

--Including------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-----------------------------------

entity TB_Limited is	
end TB_Limited;

architecture Behavioral of TB_Limited is
	constant Bit_width  :integer := 8;											--Channel width in bits
	constant Clk_period :time    := 20 ns;										--1/(20ns *10^-3) = 50MHz
		
	type State_machine is(None, Reset, Test_0, Test_1, Test_2);			--State names
	signal Test_case: State_machine;												--State machines signal
		
	component Limited
		port( Clk     :in  std_logic;
		      Rst     :in  std_logic;
				Max     :in  std_logic;
				Min     :in  std_logic;
				Pre_dir :in  std_logic;
				Dir     :in  std_logic;
				Duty    :in  std_logic_vector(7 downto 0);
				Q_Dir   :out std_logic;
				Q_Duty  :out std_logic_vector(7 downto 0) );
	end component;

	signal Clk_sig     :std_logic :='0';
	signal Rst_sig     :std_logic :='1';
	signal Max_sig     :std_logic :='1';	
	signal Min_sig     :std_logic :='1';
	signal Pre_dir_sig :std_logic :='0';
	signal Dir_sig     :std_logic := '0';
	signal Duty_sig    :std_logic_vector(7 downto 0) := (others => '0');
	signal Q_Dir_sig   :std_logic := '1';
	signal Q_Duty_sig  :std_logic_vector(7 downto 0) := (others => '0');
	
	--General control procedures===============================================================
		--Latch input on (N) falling Clk edge
		procedure wait_fclk (constant n: integer)is
		begin
			for i in 1 to n loop
				wait on Clk_sig until Clk_sig='0';
			end loop;
		end procedure wait_fclk;
		
		--Latch input on (N) rising Clk edge
		procedure wait_rclk (constant n: integer)is
		begin
			for i in 1 to n loop
				wait on Clk_sig until Clk_sig='1';
			end loop;
		end procedure wait_rclk;
		
		--Test vectors
		procedure Test_vector (constant n        :in  integer;
									  variable Vector_0 :out std_logic_vector;
									  variable Vector_1 :out std_logic_vector;
									  variable Vector_2 :out std_logic_vector;
									  variable Vector_3 :out std_logic_vector )is
				
			variable Vector_temp :std_logic_vector(n-1 downto 0) := (others => '0');
		begin
			for i in 0 to (n-1) loop
				Vector_temp := std_logic_vector(to_unsigned(i, Vector_temp'length));
				Vector_0(i)	:= '0';																				--B"0000_..._0000"
				Vector_1(i) := Vector_temp(0);																--B"1010_..._1010"
				Vector_2(i) := not Vector_temp(0);															--B"0101_..._0101"
				Vector_3(i)	:= '1';																				--B"1111_..._1111"
			end loop;
		end procedure;
		
		--Reset device under test
		procedure Reset(signal Test_case  :out State_machine;
							 signal Rst_sig    :out std_logic;
							 signal Q_Dir_sig  :in  std_logic;
							 signal Q_Duty_sig :in  std_logic_vector ) is
		begin
			--Change state
			Test_case <= Reset;
			
			--Setup stimulus
			wait_fclk(1);
			Rst_sig <= '0';				--Set reset input high
			wait_fclk(1);
			Rst_sig <= '1';				--Set reset input low
			
			--Verifying stimulus
			wait_rclk(1);
			assert (Q_Dir_sig = '0')
			report "Reset: Q_Dir are not zero after reset." severity error;
			
			assert (Q_Duty_sig = std_logic_vector(to_unsigned(0, Q_Duty_sig'length)))
			report "Reset: Q_Duty are not zero after reset." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 0=====================================================================
			--Testing Dir and Duty
		procedure Test_input0(signal   Test_case   :out State_machine;
									 signal   Rst_sig     :out std_logic;
									 signal   Max_sig     :out std_logic;	
									 signal   Min_sig     :out std_logic;
									 signal   Pre_dir_sig :out std_logic;
									 signal   Dir_sig     :out std_logic;
									 signal   Duty_sig    :out std_logic_vector;
									 signal   Q_Dir_sig   :in  std_logic;
									 signal   Q_Duty_sig  :in  std_logic_vector;
									 constant Pre_dir_set :in  std_logic ) is
			--Test vectors
			variable Vector_0 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_1 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_2 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_3 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
				
			variable Q_Duty_Test_int :integer;
			variable Q_Duty_int      :integer;
		begin
			--Reset to avoid test case dependence 	
			Reset(Test_case  => Test_case,
					Rst_sig    => Rst_sig,		
					Q_Dir_sig  => Q_Dir_sig,
					Q_Duty_sig => Q_Duty_sig );
			
			--Change state
			Test_case <= Test_0;	
			
			--Generated Test vectors
			Test_vector(n        => Bit_width,												--Numbers of bits
							Vector_0 => Vector_0,	
							Vector_1 => Vector_1,
							Vector_2 => Vector_2,
							Vector_3 => Vector_3 );
			
			--Setup stimulus 0
			wait_fclk(1);
			Min_sig      <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig      <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig  <= Pre_dir_set;
			Dir_sig      <= '1';				
			Duty_sig     <= Vector_3;
			
			--Setup stimulus 1
			wait_fclk(1);
			Min_sig      <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig      <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig  <= Pre_dir_set;
			Dir_sig      <= '0';				
			Duty_sig     <= Vector_0;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 0
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_3));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T0-E0.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')" 
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T0-E0.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 2
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_1;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 1
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T0-E1.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')" 	
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T0-E1.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 3
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_2;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 2
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_1));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T0-E2.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"	
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T0-E2.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")" 
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 3
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_2));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T0-E3.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T0-E3.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Reset stimulus
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_0;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 1=====================================================================
			--Testing Min endstop
		procedure Test_input1(signal   Test_case   :out State_machine;
									 signal   Rst_sig     :out std_logic;
									 signal   Max_sig     :out std_logic;	
									 signal   Min_sig     :out std_logic;
									 signal   Pre_dir_sig :out std_logic;
									 signal   Dir_sig     :out std_logic;
									 signal   Duty_sig    :out std_logic_vector;
									 signal   Q_Dir_sig   :in  std_logic;
									 signal   Q_Duty_sig  :in  std_logic_vector;
									 constant Pre_dir_set :in  std_logic ) is
			--Test vectors
			variable Vector_0 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_1 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_2 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_3 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
				
			variable Q_Duty_Test_int :integer;
			variable Q_Duty_int      :integer;
		begin
			--Reset to avoid test case dependence 	
			Reset(Test_case  => Test_case,
					Rst_sig    => Rst_sig,		
					Q_Dir_sig  => Q_Dir_sig,
					Q_Duty_sig => Q_Duty_sig );
			
			--Change state
			Test_case <= Test_1;	
			
			--Generated Test vectors
			Test_vector(n        => Bit_width,												--Numbers of bits
							Vector_0 => Vector_0,	
							Vector_1 => Vector_1,
							Vector_2 => Vector_2,
							Vector_3 => Vector_3 );
			
			--Setup stimulus 0
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_3;
			
			--Setup stimulus 1
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_3;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 0
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_3));
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T1-E0.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E0.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")" 
					severity error;
			
			--Setup stimulus 2
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_0;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 1
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_3));
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T1-E1.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"		
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E1.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 3
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_0;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 2
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T1-E2.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')" 	
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E2.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 4
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_1;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 3
			--Expected outputs -----------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T1-E3.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"   
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E3.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 5
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_1;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 4
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_1));
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T1-E4.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"   	 	
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E4.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")" 
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 5
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_1));
			else
				Q_Duty_Test_int := 0;
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T1-E5.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"  
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E5.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"
					severity error;
			
			--Setup stimulus 6
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_2;
			
			--Setup stimulus 7
			wait_fclk(1);
			Min_sig     <= '0';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_2;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 6
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_2));
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '1')
				report "[T1-E6.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"  
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E6.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")" 
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 7
			--Expected outputs -----------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_2));
			else
				Q_Duty_Test_int := 0;
			end if;
			--Actual outputs -------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages --------------------------------------------------------------------------------
			assert(Q_Dir_sig = '0')
				report "[T1-E7.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"   
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T1-E7.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"  
					severity error;
			
			--Reset stimulus
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_0;
			
			--Change state
			Test_case <= None;
		end procedure;
		
	--Procedure for test 2=====================================================================
			--Testing Max endstop
		procedure Test_input2(signal   Test_case   :out State_machine;
									 signal   Rst_sig     :out std_logic;
									 signal   Max_sig     :out std_logic;	
									 signal   Min_sig     :out std_logic;
									 signal   Pre_dir_sig :out std_logic;
									 signal   Dir_sig     :out std_logic;
									 signal   Duty_sig    :out std_logic_vector;
									 signal   Q_Dir_sig   :in  std_logic;
									 signal   Q_Duty_sig  :in  std_logic_vector;
									 constant Pre_dir_set :in  std_logic ) is
			--Test vectors
			variable Vector_0 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_1 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_2 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
			variable Vector_3 :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
				
			variable Q_Duty_Test_int :integer;
			variable Q_Duty_int      :integer;
		begin
			--Reset to avoid test case dependence 	
			Reset(Test_case  => Test_case,
					Rst_sig    => Rst_sig,		
					Q_Dir_sig  => Q_Dir_sig,
					Q_Duty_sig => Q_Duty_sig );
			
			--Change state
			Test_case <= Test_2;	
			
			--Generated Test vectors
			Test_vector(n        => Bit_width,												--Numbers of bits
							Vector_0 => Vector_0,	
							Vector_1 => Vector_1,
							Vector_2 => Vector_2,
							Vector_3 => Vector_3 );
			
			--Setup stimulus 0
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_3;
			
			--Setup stimulus 1
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_3;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 0
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_3));
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '0')
				report "[T2-E0.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')" 
					severity error;
			
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E0.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"  
					severity error;
			
			--Setup stimulus 2
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_0;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 1
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_3));
			else
				Q_Duty_Test_int := 0;
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '1')
				report "[T2-E1.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"  
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E1.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	
					severity error;
			
			--Setup stimulus 3
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_0;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 2
			--Expected outputs -------------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '0')
				report "[T2-E2.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"   
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E2.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	
					severity error;
			
			--Setup stimulus 4
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_1;
			
			--Verifying response to stimulus 3
			--Expected outputs -------------------------------
			Q_Duty_Test_int := to_integer(unsigned(Vector_0));
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			wait_rclk(1);
			assert(Q_Dir_sig = '1')
				report "[T2-E3.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')" 
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E3.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"		
					severity error;
			
			--Setup stimulus 5
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_1;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 4
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_1));
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '0')
				report "[T2-E4.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')"  
					severity error;
			
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E4.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	 	
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 5
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_1));
			else
				Q_Duty_Test_int := 0;
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '1')
				report "[T2-E5.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')" 
					severity error;
			
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E5.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	  
					severity error;
			
			--Setup stimulus 6
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_2;
			
			--Setup stimulus 7
			wait_fclk(1);
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '0';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '1';				
			Duty_sig    <= Vector_2;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 6
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := 0;
			else
				Q_Duty_Test_int := to_integer(unsigned(Vector_2));
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '0')
				report "[T2-E6.0] Output: Q_Dir are not correct (Q_Dir='1' should be: Q_Dir='0')" 
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E6.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	 	
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus 7
			--Expected outputs -------------------------------
			if(Pre_dir_sig = '0') then
				Q_Duty_Test_int := to_integer(unsigned(Vector_2));
			else
				Q_Duty_Test_int := 0;
			end if;
			--Actual outputs ---------------------------------
			Q_Duty_int := to_integer(unsigned(Q_Duty_sig));
			--Error messages ---------------------------------
			assert(Q_Dir_sig = '1')
				report "[T2-E7.0] Output: Q_Dir are not correct (Q_Dir='0' should be: Q_Dir='1')"  
					severity error;
				
			assert(Q_Duty_int = Q_Duty_Test_int)
				report "[T2-E7.1] Output: Q_Duty are not correct (Q_Duty=" & integer'image(Q_Duty_int) & " should be: Q_Duty=" & integer'image(Q_Duty_Test_int) & ")"	 
					severity error;
			
			--Reset stimulus
			Min_sig     <= '1';							--1=Min end stop not active, 0= Min end stop active
			Max_sig     <= '1';							--1=Max end stop not active, 0= Max end stop active
			Pre_dir_sig <= Pre_dir_set;
			Dir_sig     <= '0';				
			Duty_sig    <= Vector_0;
			
			--Change state
			Test_case <= None;
		end procedure;
		
	--Unit under test====================================================================================	
	begin   
		uut: Limited
		port map( Clk     => Clk_sig,
					 Rst     => Rst_sig,
					 Max     => Max_sig,
					 Min     => Min_sig,
					 Pre_dir => Pre_dir_sig,
					 Dir     => Dir_sig,
					 Duty    => Duty_sig,
					 Q_Dir   => Q_Dir_sig,
					 Q_Duty  => Q_Duty_sig );
			
		--Main Clock
		Clk_process: process
		begin
			Clk_sig <= '0';
			wait for Clk_period/2;
			Clk_sig <= '1';
			wait for Clk_period/2;
		end process;
		
		--Test sequence====================================================================================
		Test: process
		begin 
			wait for 10 ns;												--Startup time					
			
			---------------------------------------
			--Testing Dir and Duty
			---------------------------------------
			for I in std_logic range '0' to '1' loop
				Test_input0(Test_case   => Test_case,
								Rst_sig     => Rst_sig,
								Max_sig     => Max_sig,
								Min_sig     => Min_sig,
								Pre_dir_sig => Pre_dir_sig,
								Pre_dir_set => I,
								Dir_sig     => Dir_sig,
								Duty_sig    => Duty_sig,
								Q_Dir_sig   => Q_Dir_sig,
								Q_Duty_sig  => Q_Duty_sig );
			end loop;
			
			---------------------------------------
			--Testing Min endstop
			---------------------------------------
			for I in std_logic range '0' to '1' loop
				Test_input1(Test_case   => Test_case,
								Rst_sig     => Rst_sig,
								Max_sig     => Max_sig,
								Min_sig     => Min_sig,
								Pre_dir_sig => Pre_dir_sig,
								Pre_dir_set => I,
								Dir_sig     => Dir_sig,
								Duty_sig    => Duty_sig,
								Q_Dir_sig   => Q_Dir_sig,
								Q_Duty_sig  => Q_Duty_sig );
			end loop;
			
			---------------------------------------
			--Testing Max endstop
			---------------------------------------
			for I in std_logic range '0' to '1' loop
				Test_input2(Test_case   => Test_case,
								Rst_sig     => Rst_sig,
								Max_sig     => Max_sig,
								Min_sig     => Min_sig,
								Pre_dir_sig => Pre_dir_sig,
								Pre_dir_set => I,
								Dir_sig     => Dir_sig,
								Duty_sig    => Duty_sig,
								Q_Dir_sig   => Q_Dir_sig,
								Q_Duty_sig  => Q_Duty_sig );
			end loop;
			
			--Reseting------------------
--			Reset(Test_case  => Test_case,
--					Rst_sig    => Rst_sig,		
--					Q_Dir_sig  => Q_Dir_sig,
--					Q_Duty_sig => Q_Duty_sig );
			wait;
		end process;
end Behavioral;