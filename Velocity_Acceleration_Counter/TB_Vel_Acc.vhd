--Description ===================================================================
--   Self verifying Modular testbench for the Velocity and Acceleration Counter.
--Information ===================================================================
--   File name:      TB_Vel_Acc.VHDL
--   Target file:	   Vel_Acc.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:	VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.0        | Major.minor.patch
--   Created:        20-03-2017
--   Modified:       23-03-2017   | Base functionality validted in testbench
--===============================================================================

--Including----------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
---------------------------------

entity TB_Vel_Acc is
end TB_Vel_Acc;

architecture Behavioral of TB_Vel_Acc is
	constant Bit_width  :integer := 8;															--16 Channel width in bits
	constant Clk_period :time    := 20 ns;														--1/(20ns *10^-3) = 50MHz
		
	type State_machine is(None, Reset, Test_0, Test_1, Test_2, Test_3 , Test_4);	--State names
	signal Test_case: State_machine;																--State machines signal
		
	component Vel_Acc
		port( Clk   :in  std_logic;
		      Rst   :in  std_logic;
				Pulse :in  std_logic;	
				Dir   :in  std_logic;
				Mode  :in  std_logic;
				Vel   :out std_logic_vector(Bit_width-1 downto 0);
				Acc   :out std_logic_vector(Bit_width-1 downto 0) );
	end component;
		
	signal Clk_sig   :std_logic :='0';
	signal Rst_sig   :std_logic :='1';
	signal Pulse_sig :std_logic :='0';
	signal Dir_sig   :std_logic :='0';
	signal Mode_sig  :std_logic :='0';
	signal Vel_sig   :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
	signal Acc_sig   :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
		
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
		procedure Reset(signal Test_case :out State_machine;
							 signal Rst       :out std_logic;
							 signal Vel       :in  std_logic_vector;
							 signal Acc       :in  std_logic_vector) is
				
			variable Vel_start :std_logic_vector(Bit_width-1 downto 0) := ('0', others => '1');
			
		begin
			--Change state
			Test_case <= Reset;
			
			--Setup stimulus
			wait_fclk(1);
			Rst <= '0';					--Set reset input not active
			wait_fclk(1);
			Rst <= '1';					--Set reset input active
			
			--Verifying stimulus
			wait_rclk(1);
				
			assert (Vel = Vel_start)
			report "Reset: Vel are not correct after reset." severity error;
				
			assert (Acc = std_logic_vector(to_unsigned(0, Acc'length)))
			report "Reset: Acc are not zero after reset." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 0=====================================================================
			--Testing constant velocity
		procedure Test_input0(signal   Test_case :out State_machine;
									 signal   Rst   	  :out std_logic;
									 signal   Pulse	  :out std_logic;
									 signal   Dir	     :out std_logic;
									 signal   Mode	     :out std_logic;
									 constant Dir_set	  :in  std_logic;
									 constant Mode_set  :in  std_logic;
									 signal   Vel		  :in  std_logic_vector;
									 signal   Acc 		  :in  std_logic_vector) is
				
			variable Acc_Test_int :integer;																	--Acceleration test as integer type
			variable Vel_Test_int :integer;																	--Velocity test as integer type
			variable Vel_int      :integer;
			variable Acc_int      :integer;
		begin
			--Reset to avoid test case dependence 
			Reset(Test_case => Test_case,
					Rst       => Rst,		
					Vel       => Vel,
					Acc       => Acc);
				
			--Change state
			Test_case <= Test_0;
			
			--Setup stimulus 0
			wait_fclk(5);
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Setup stimulus 1
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(2);
			for i in 0 to 2 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int :=   5;
					Acc_Test_int := 122;
				else
					Vel_Test_int :=  -5;
					Acc_Test_int := 122;	
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T0-E0.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;
						
				assert (Acc_int = Acc_Test_int)
					report "[T0-E0.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;
				wait_rclk(1);
			end loop;
			
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=   5;
				Acc_Test_int := 122;
			else
				Vel_Test_int :=  -5;
				Acc_Test_int := 122;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E1.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E1.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;		
			
			
			--Setup stimulus 2
			wait_fclk(1);
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(1);
			
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=   5;
				Acc_Test_int := 122;
			else
				Vel_Test_int :=  -5;
				Acc_Test_int := 122;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E2.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E2.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			
			
			--Setup stimulus 3
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=   5;
				Acc_Test_int := 122;
			else
				Vel_Test_int :=  -5;
				Acc_Test_int := 122;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E3.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E3.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			
			
			--Verifying response to stimulus 2
			wait_rclk(1);
			for i in 0 to 2 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int := 5;
					Acc_Test_int := 0;
				else
					Vel_Test_int := -5;
					Acc_Test_int :=  0;				
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T0-E4.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T0-E4.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 5;
				Acc_Test_int := 0;
			else
				Vel_Test_int := -5;
				Acc_Test_int :=  0;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E5.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E5.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;		
			
			
			--Setup stimulus 4
			wait_fclk(1);
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 2
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 5;
				Acc_Test_int := 0;
			else
				Vel_Test_int := -5;
				Acc_Test_int :=  0;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E6.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E6.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			
			
			--Setup stimulus 5
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 3
			wait_rclk(1);
			for i in 0 to 1 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int := 5;
					Acc_Test_int := 0;
				else
					Vel_Test_int := -5;
					Acc_Test_int :=  0;				
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T0-E7.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T0-E7.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 5;
				Acc_Test_int := 0;
			else
				Vel_Test_int := -5;
				Acc_Test_int :=  0;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T0-E8.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T0-E8.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			
			--Reset stimulus
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= '0';
			Mode	<= '0';
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 1=====================================================================
			--Testing increasing velocity
		procedure Test_input1(signal   Test_case :out State_machine;
									 signal   Rst   	  :out std_logic;
									 signal   Pulse	  :out std_logic;
									 signal   Dir	     :out std_logic;
									 signal   Mode	     :out std_logic;
									 constant Dir_set	  :in  std_logic;
									 constant Mode_set  :in  std_logic;
									 signal   Vel		  :in  std_logic_vector;
									 signal   Acc 		  :in  std_logic_vector) is
				
			variable Acc_Test_int :integer;																	--Acceleration test as integer type
			variable Vel_Test_int :integer;																	--Velocity test as integer type
			variable Vel_int      :integer;
			variable Acc_int      :integer;
		begin
			--Reset to avoid test case dependence 
			Reset(Test_case => Test_case,
					Rst       => Rst,		
					Vel       => Vel,
					Acc       => Acc);
				
			--Change state
			Test_case <= Test_1;
				
			--Setup stimulus 0
			wait_fclk(15);
			Pulse <= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
				
			--Setup stimulus 1
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
				
			--Verifying response to stimulus 0
			wait_rclk(2);
			for i in 0 to 7 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int :=  15;
					Acc_Test_int := 112;
				else
					Vel_Test_int := -15;
					Acc_Test_int := 112;				
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T1-E0.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T1-E0.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=  15;
				Acc_Test_int := 112;
			else
				Vel_Test_int := -15;
				Acc_Test_int := 112;				
			end if;
				--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E1.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E1.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
				
			--Setup stimulus 2
			wait_fclk(1);
			Pulse	  <= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
				
			--Verifying response to stimulus 0
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=  15;
				Acc_Test_int := 112;
			else
				Vel_Test_int := -15;
				Acc_Test_int := 112;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E2.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T1-E2.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
				
			--Setup stimulus 3
			wait_fclk(1);
			Pulse	  <= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
				
			--Verifying response to stimulus 0
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int :=  15;
				Acc_Test_int := 112;
			else
				Vel_Test_int := -15;
				Acc_Test_int := 112;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E3.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T1-E3.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
				
			--Verifying response to stimulus 2
			wait_rclk(1);
			for i in 0 to 2 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int := 10;
					Acc_Test_int :=  5;
				else
					Vel_Test_int := -10;
					Acc_Test_int :=   5;				
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T1-E4.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
						
				assert (Acc_int = Acc_Test_int)
					report "[T1-E4.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 10;
				Acc_Test_int :=  5;
			else
				Vel_Test_int := -10;
				Acc_Test_int :=   5;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E5.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
						
			assert (Acc_int = Acc_Test_int)
				report "[T1-E5.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			--Setup stimulus 4
			wait_fclk(1);
			Pulse	  <= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
				
			--Verifying response to stimulus 2
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 10;
				Acc_Test_int :=  5;
			else
				Vel_Test_int := -10;
				Acc_Test_int :=   5;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E6.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E6.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 10;
				Acc_Test_int :=  5;
			else
				Vel_Test_int := -10;
				Acc_Test_int :=   5;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E7.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E7.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 5;
				Acc_Test_int := 5;
			else
				Vel_Test_int := -5;
				Acc_Test_int :=  5;				
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E8.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E8.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			Vel_Test_int := 0;
			Acc_Test_int := 5;				
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E9.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E9.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			wait_rclk(1);	
			
			--Expected outputs ------------------------------------------------------
			Vel_Test_int := 0;
			Acc_Test_int := 0;				
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E10.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E10.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			wait_rclk(1);	
			
			--Expected outputs ------------------------------------------------------
			Vel_Test_int := 0;
			Acc_Test_int := 0;				
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T1-E11.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T1-E11.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			--Reset stimulus
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= '0';
			Mode	<= '0';
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 2=====================================================================
			--Testing decreasing velocity
		procedure Test_input2(signal   Test_case :out State_machine;
									 signal   Rst   	  :out std_logic;
									 signal   Pulse	  :out std_logic;
									 signal   Dir	     :out std_logic;
									 signal   Mode	     :out std_logic;
									 constant Dir_set	  :in  std_logic;
									 constant Mode_set  :in  std_logic;
									 signal   Vel		  :in  std_logic_vector;
									 signal   Acc 		  :in  std_logic_vector) is
				
			variable Acc_Test_int :integer;																	--Acceleration test as integer type
			variable Vel_Test_int :integer;																	--Velocity test as integer type
			variable Vel_int      :integer;
			variable Acc_int      :integer;	
		begin
			--Reset to avoid test case dependence 
			Reset(Test_case => Test_case,
					Rst       => Rst,			
					Vel       => Vel,
					Acc       => Acc);
				
			--Change state
			Test_case <= Test_2;
			
			--Setup stimulus 0
			wait_fclk(5);
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Setup stimulus 1
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(2);
			for i in 0 to 6 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int :=   5;
					Acc_Test_int := 122;
				else
					Vel_Test_int :=  -5;
					Acc_Test_int := 122;				
				end if;				
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T2-E0.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T2-E0.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;
					
				wait_rclk(1);
			end loop;
				
				
			for I in 1 to 3 loop
				--Expected outputs ------------------------------------------------------	
				if(Dir = '0') then
					if(Mode_set = '0') then
						Vel_Test_int :=   5;
						Acc_Test_int := 122;			
					else
						Vel_Test_int :=  Vel_Test_int +1;
						Acc_Test_int := -I;
					end if;
				else
					if(Mode_set = '0') then
						Vel_Test_int :=  -5;
						Acc_Test_int := 122;	
					else
						Vel_Test_int := Vel_Test_int -1;
						Acc_Test_int := -I;
					end if;
				end if;
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T2-E1.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T2-E1.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;
				
				wait_rclk(1);
			end loop;
			
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   5;
					Acc_Test_int := 122;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=  -5;
					Acc_Test_int := 122;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E2.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T2-E2.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Setup stimulus 2
			wait_fclk(1);
			Pulse	<= '1';
			Dir   <= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(1);
				
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   5;
					Acc_Test_int := 122;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=  -5;
					Acc_Test_int := 122;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E3.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T2-E3.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Setup stimulus 3
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 0
			wait_rclk(1);
				
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   5;
					Acc_Test_int := 122;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=  -5;
					Acc_Test_int := 122;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E4.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T2-E4.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Verifying response to stimulus 2
			wait_rclk(1);
			for i in 0 to 12 loop
				--Expected outputs ------------------------------------------------------
				if(Dir = '0') then
					Vel_Test_int := 12;
					Acc_Test_int := -7;
				else
					Vel_Test_int := -12;
					Acc_Test_int :=  -7;				
				end if;				
				--Actual outputs --------------------------------------------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T2-E5.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T2-E5.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
				
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 12;
				Acc_Test_int := -7;
			else
				Vel_Test_int := -12;
				Acc_Test_int :=  -7;				
			end if;				
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E6.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T2-E6.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Setup stimulus 4
			wait_fclk(1);
			Pulse	<= '1';
			Dir	<= Dir_set;
			
			--Verifying response to stimulus 2
			wait_rclk(1);	
				
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int := 12;
					Acc_Test_int := -7;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int := -12;
					Acc_Test_int :=  -7;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := -1;
				end if;
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E7.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
					
			assert (Acc_int = Acc_Test_int)
				report "[T2-E7.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Setup stimulus 5
			wait_fclk(1);
			Pulse <= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Verifying response to stimulus 2
			wait_rclk(1);	
				
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int := 12;
					Acc_Test_int := -7;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int := -12;
					Acc_Test_int :=  -7;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E8.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T2-E8.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
				
			--Verifying response to stimulus 4
			wait_rclk(1);
			
			--Expected outputs ------------------------------------------------------
			if(Dir = '0') then
				Vel_Test_int := 15;
				Acc_Test_int := -3;
			else
				Vel_Test_int := -15;
				Acc_Test_int :=  -3;				
			end if;				
			--Actual outputs --------------------------------------------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T2-E10.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T2-E10.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Reset stimulus
			wait_fclk(2);
			Pulse	<= '0';
			Dir	<= '0';
			Mode	<= '0';
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 3=====================================================================
			--Testing velocity range in both directions
		procedure Test_input3(signal   Test_case :out State_machine;
									 signal   Rst   	  :out std_logic;
									 signal   Pulse	  :out std_logic;
									 signal   Dir	     :out std_logic;
									 signal   Mode	     :out std_logic;
									 constant Dir_set	  :in  std_logic;
									 constant Mode_set  :in  std_logic;
									 signal   Vel		  :in  std_logic_vector;
									 signal   Acc 		  :in  std_logic_vector) is
				
			variable Acc_Test_int :integer;																	--Acceleration test as integer type
			variable Vel_Test_int :integer;																	--Velocity test as integer type
			variable Vel_int      :integer;
			variable Acc_int      :integer;	
		begin
			--Start stimulus
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Reset to avoid test case dependence 
			Reset(Test_case => Test_case,
					Rst       => Rst,			
					Vel       => Vel,
					Acc       => Acc);
				
			--Change state
			Test_case <= Test_3;
			
			--Setup stimulus 0
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			wait_rclk(2);
			
			--Verifying response to start stimulus
			for i in 0 to 1 loop
				--Expected outputs -------------------
				if(Dir = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;
				else
					Vel_Test_int :=   0;
					Acc_Test_int := 127;				
				end if;				
				--Actual outputs ---------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -----------------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T3-E0.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T3-E0.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus
			for i in 1 to 123 loop
				--Expected outputs ----------------
				if(Dir = '0') then
					if(Mode_set = '0') then
						Vel_Test_int :=   0;
						Acc_Test_int := 127;			
					else
						Vel_Test_int :=  I;
						Acc_Test_int := -I;
					end if;
				else
					if(Mode_set = '0') then
						Vel_Test_int :=   0;
						Acc_Test_int := 127;	
					else
						Vel_Test_int := -I;
						Acc_Test_int := -I;
					end if;
				end if;
				--Actual outputs ------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -----------------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T3-E1.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
							
				assert (Acc_int = Acc_Test_int)
					report "[T3-E1.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus
			--Expected outputs ----------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs ------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -----------------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T3-E2.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T3-E2.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
				
			--Setup stimulus 1
			wait_fclk(1);
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			wait_rclk(1);
			
			--Verifying response to stimulus
			--Expected outputs ----------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs ------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T3-E3.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T3-E3.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			--Setup stimulus 2
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			wait_rclk(1);
			
			--Verifying response to stimulus
			--Expected outputs ----------------
			if(Dir = '0') then
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;			
				else
					Vel_Test_int := Vel_Test_int +1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			else
				if(Mode_set = '0') then
					Vel_Test_int :=   0;
					Acc_Test_int := 127;	
				else
					Vel_Test_int := Vel_Test_int -1;
					Acc_Test_int := Acc_Test_int -1;
				end if;
			end if;
			--Actual outputs ------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T3-E4.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T3-E4.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;
			
			wait_rclk(1);
			
			--Verifying response to stimulus
			--Expected outputs ----------------
			if(Dir = '0') then
					Vel_Test_int :=  127;
					Acc_Test_int := -127;
				else
					Vel_Test_int := -127;
					Acc_Test_int := -127;				
				end if;
			--Actual outputs ------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T3-E5.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T3-E5.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			
			--Reset stimulus
			wait_fclk(2);
			Pulse	<= '0';
			Dir	<= '0';
			Mode	<= '0';
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 4=====================================================================
			--Testing velocity and Acceleration range when pulse input is outside counter range
		procedure Test_input4(signal   Test_case :out State_machine;
									 signal   Rst   	  :out std_logic;
									 signal   Pulse	  :out std_logic;
									 signal   Dir	     :out std_logic;
									 signal   Mode	     :out std_logic;
									 constant Dir_set	  :in  std_logic;
									 constant Mode_set  :in  std_logic;
									 signal   Vel		  :in  std_logic_vector;
									 signal   Acc 		  :in  std_logic_vector) is
				
			variable Acc_Test_int :integer;																	--Acceleration test as integer type
			variable Vel_Test_int :integer;																	--Velocity test as integer type
			variable Vel_int      :integer;
			variable Acc_int      :integer;	
		begin
			--Start stimulus
			Pulse	<= '1';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			--Reset to avoid test case dependence 
			Reset(Test_case => Test_case,
					Rst       => Rst,			
					Vel       => Vel,
					Acc       => Acc);
				
			--Change state
			Test_case <= Test_4;
			
			-----------------
			--Setup stimulus 0
			wait_fclk(1);
			Pulse	<= '0';
			Dir	<= Dir_set;
			Mode	<= Mode_set;
			
			wait_rclk(2);
			
			--Verifying response to start stimulus
			for i in 0 to 1 loop
				--Expected outputs -------------------
				Vel_Test_int :=   0;
				Acc_Test_int := 127;							
				--Actual outputs ---------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -----------------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T4-E0.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
					
				assert (Acc_int = Acc_Test_int)
					report "[T4-E0.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus---------
			for i in 1 to 126 loop
				--Expected outputs ----------------
				if(Dir = '0') then
					if(Mode_set = '0') then
						Vel_Test_int :=   0;
						Acc_Test_int := 127;			
					else
						Vel_Test_int :=  I;
						Acc_Test_int := -I;
					end if;
				else
					if(Mode_set = '0') then
						Vel_Test_int :=   0;
						Acc_Test_int := 127;	
					else
						Vel_Test_int := -I;
						Acc_Test_int := -I;
					end if;
				end if;
				--Actual outputs ------------------
				Acc_int := to_integer(signed(Acc));
				Vel_int := to_integer(signed(Vel));
				--Error messages -----------------------------------------------------------------------------------------------------------------------
				assert (Vel_int = Vel_Test_int)
					report "[T4-E1.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
						severity error;	
							
				assert (Acc_int = Acc_Test_int)
					report "[T4-E1.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
						severity error;	
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus
			--Expected outputs ----------------
			if(Dir = '0') then
					Vel_Test_int :=  127;
					Acc_Test_int := -127;			
				else
					Vel_Test_int := -127;
					Acc_Test_int := -127;
				end if;		
			--Actual outputs ------------------
			Acc_int := to_integer(signed(Acc));
			Vel_int := to_integer(signed(Vel));
			--Error messages -----------------------------------------------------------------------------------------------------------------------
			assert (Vel_int = Vel_Test_int)
				report "[T4-E2.0] Output: Vel is not correct (Vel=" & integer'image(Vel_int) & " should be: Vel=" & integer'image(Vel_Test_int) & ")"
					severity error;	
				
			assert (Acc_int = Acc_Test_int)
				report "[T4-E2.1] Output: Acc is not correct (Acc=" & integer'image(Acc_int) & " should be: Acc=" & integer'image(Acc_Test_int) & ")"
					severity error;	
			wait_rclk(1);
			
			--Reset stimulus
			wait_fclk(2);
			Pulse	<= '0';
			Dir	<= '0';
			Mode	<= '0';
			
			--Change state
			Test_case <= None;
		end procedure;
		
	--Unit under test====================================================================================	
	begin   
		uut: Vel_Acc
		port map( Clk   => Clk_sig,
					 Rst   => Rst_sig,
					 Pulse => Pulse_sig,
					 Dir   => Dir_sig,
					 Mode  => Mode_sig,
					 Vel   => Vel_sig,
					 Acc   => Acc_sig );
			
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
			wait for 10 ns;									--Startup time					
			
			-----------------------------------------------------------------------------------
			--Testing constant velocity in both directions
			-----------------------------------------------------------------------------------
			for U in std_logic range '0' to '1' loop
				for I in std_logic range '0' to '1' loop
					Test_input0(Test_case => Test_case,
									Rst       => Rst_sig,
									Pulse     => Pulse_sig,
									Dir       => Dir_sig,
									Mode      => Mode_sig,
									Dir_set   => I,				--Direction: '0' = CW,     '1' = CCW
									Mode_set  => U,				--Mode:      '0' = Normal, '1' = Predictive mode
									Vel		 => Vel_sig,
									Acc       => Acc_sig);
				end loop;	
			end loop;
			
			-----------------------------------------------------------------------------------
			--Testing increasing acceleration in both directions and modes
			-----------------------------------------------------------------------------------
			for U in std_logic range '0' to '1' loop
				for I in std_logic range '0' to '1' loop
					Test_input1(Test_case => Test_case,
									Rst       => Rst_sig,
									Pulse     => Pulse_sig,
									Dir       => Dir_sig,
									Mode      => Mode_sig,
									Dir_set   => I,				--Direction: '0' = CW,     '1' = CCW
									Mode_set  => U,				--Mode:      '0' = Normal, '1' = Predictive mode
									Vel		 => Vel_sig,
									Acc       => Acc_sig);
				end loop;	
			end loop;
			
			-----------------------------------------------------------------------------------
			--Testing decreasing acceleration in both directions and modes
			-----------------------------------------------------------------------------------
			for U in std_logic range '0' to '1' loop
				for I in std_logic range '0' to '1' loop
					Test_input2(Test_case => Test_case,
									Rst       => Rst_sig,
									Pulse     => Pulse_sig,
									Dir       => Dir_sig,
									Mode      => Mode_sig,
									Dir_set   => I,				--Direction: '0' = CW,     '1' = CCW
									Mode_set  => U,				--Mode:      '0' = Normal, '1' = Predictive mode
									Vel		 => Vel_sig,
									Acc       => Acc_sig);
				end loop;
			end loop;
			
			-----------------------------------------------------------------------------------
			--Testing velocity and Acceleration range in both directions and modes
			-----------------------------------------------------------------------------------
			for U in std_logic range '0' to '1' loop
				for I in std_logic range '0' to '1' loop
					Test_input3(Test_case => Test_case,
									Rst       => Rst_sig,
									Pulse     => Pulse_sig,
									Dir       => Dir_sig,
									Mode      => Mode_sig,
									Dir_set   => I,				--Direction: '0' = CW,     '1' = CCW
									Mode_set  => U,				--Mode:      '0' = Normal, '1' = Predictive mode
									Vel		 => Vel_sig,
									Acc       => Acc_sig);
				end loop;
			end loop;
			
			-----------------------------------------------------------------------------------
			--Testing velocity and Acceleration range when pulse input is outside counter range
			-----------------------------------------------------------------------------------
			for U in std_logic range '0' to '1' loop
				for I in std_logic range '0' to '1' loop
					Test_input4(Test_case => Test_case,
									Rst       => Rst_sig,
									Pulse     => Pulse_sig,
									Dir       => Dir_sig,
									Mode      => Mode_sig,
									Dir_set   => I,				--Direction: '0' = CW,     '1' = CCW
									Mode_set  => U,				--Mode:      '0' = Normal, '1' = Predictive mode
									Vel		 => Vel_sig,
									Acc       => Acc_sig);
				end loop;
			end loop;
			
			-----------------------------------------------------------------------------------
			--Testing Reseting
			-----------------------------------------------------------------------------------
--			Reset(Test_case => Test_case,
--					Rst       => Rst_sig,		
--					Vel       => Vel_sig,
--					Acc       => Acc_sig);
			wait;
		end process;
end Behavioral;