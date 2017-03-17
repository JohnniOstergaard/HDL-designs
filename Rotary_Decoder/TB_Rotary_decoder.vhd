--Description ===================================================================
--   Self verifying Modular testbench for the Rotary_decoder.
--Information ===================================================================
--   File name:      TB_Rotary_decoder.VHDL
--   Target file:    Rotary_decoder.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:  VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.0        | Major.minor.patch
--   Created:        04.01.2017
--   Modified:       04-01-2017   | Base functionality validted in testbench
--===============================================================================

--Including----------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
---------------------------------

entity TB_Rotary_decoder is
end TB_Rotary_decoder;

architecture Behavioral of TB_Rotary_decoder is
	constant Clk_period :time := 200 ns;						--1/(200ns *10^-3) = 5MHz
		
	type State_machine is(None, Reset, Test_0, Test_1, Test_2, Test_3, Test_4);	--State names
	signal Test_case: State_machine;												--State machines signal
		
	component Rotary_decoder
		port( Clk   :in  std_logic;
		      Rst   :in  std_logic;
		      Mode  :in  std_logic;
		      A     :in  std_logic;
		      B     :in  std_logic;
		      Z     :in  std_logic;
		      Dir   :out std_logic;
		      Pulse :out std_logic;
		      Rot   :out std_logic );
	end component;

	signal Clk_sig   :std_logic :='0';
	signal Rst_sig   :std_logic :='1';
	signal Mode_sig  :std_logic :='0';
	signal A_sig     :std_logic :='1';
	signal B_sig     :std_logic :='1';
	signal Z_sig     :std_logic :='1';
	signal Dir_sig   :std_logic :='0';
	signal Pulse_sig :std_logic :='0';
	signal Rot_sig   :std_logic :='0';
		
	signal Encoder_Ena :std_logic :='0';
	signal Encoder_CW  :std_logic :='0';
	signal count       :unsigned(1 downto 0) := (others => '0');
	
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
		
		--Reset device under test
		procedure Reset(signal Test_case :out State_machine;
				signal Rst       :out std_logic;
				signal Dir       :in  std_logic;
				signal Pulse     :in  std_logic;
				signal Rot       :in  std_logic ) is
		begin
			--Change state
			Test_case <= Reset;
			
			--Setup stimulus
			wait_fclk(1);
			Rst <= '0';				--Set low to activate reset 
			wait_fclk(1);
			Rst <= '1';				--Set high to deactivate reset
			
			--Verifying stimulus
			wait_rclk(1);
			assert (Dir = '0')
			report "Reset: Dir are not zero after reset." severity error;
			
			assert (Pulse = '0')
			report "Reset: Pulse are not zero after reset." severity error;
			
			assert (Rot = '0')
			report "Reset: Rot are not zero after reset." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 0=====================================================================
			--Testing the CWW encoder input in mode 0
		procedure Test_input0(signal Test_case     :out State_machine;
				      constant Encoder_Dir :in  std_logic;
				      signal Encoder_Ena   :out std_logic;
				      signal Encoder_CW    :out std_logic;
				      signal Rst           :out std_logic;
				      signal Mode          :out std_logic;
				      signal Z  	   :out std_logic;
				      signal Dir  	   :in  std_logic;
				      signal Pulse         :in  std_logic;
				      signal Rot   	   :in  std_logic ) is
		begin
			--Reset to avoid test case dependence
			Reset(Test_case => Test_case,
			      Rst       => Rst,
			      Dir 	=> Dir,
			      Pulse   	=> Pulse,
			      Rot  	=> Rot );
			
			--Change state
			Test_case <= Test_0;	
			
			--Setup stimulus 0-------------------------------------------------------------
			wait_rclk(1);
			Mode        <= '0';
			Encoder_Ena <= '1';					--Enable encoder
			Encoder_CW  <= Encoder_Dir;				--Encoder Dir: 1=CW, 0=CWW
			z 	    <= '1';					--Set rotation input
				
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(6);
			
			for i in 0 to 1 loop
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				
				for i in 0 to 2 loop
					wait_rclk(1);
					if(Encoder_Dir = '0') then
						assert(Dir = '1')
						report "Output: Dir are not correct." severity error;
					else
						assert(Dir = '0')
						report "Output: Dir are not correct." severity error;
					end if;
				
					assert(Pulse = '0')
					report "Output: Pulse are not correct." severity error;
					
					assert(Rot = '0')
					report "Output: Rot are not correct." severity error;
				end loop;
				wait_rclk(1);
			end loop;
			
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '0';
			Encoder_Ena <= '0';			--Enable encoder
			Encoder_CW  <= '1';			--Encoder Dir: 1=CW, 0=CWW
			z 	    <= '1';			--Set rotation input
			
			--Verifying response to stimulus 0---------------------------------------------
			for i in 0 to 2 loop
				wait_rclk(1);
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
			
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
			end loop;
			wait_rclk(1);
				
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Verifying response to stimulus 1---------------------------------------------
			wait_rclk(1);
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
			
			assert(Pulse = '0')
			report "Output: Pulse are not correct." severity error;
			
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 1=====================================================================
			--Testing the CW encoder input in mode 0
		procedure Test_input1(signal Test_case :out State_machine;
				      signal Rst       :out std_logic;
				      signal Z         :out std_logic;
				      signal Dir       :in  std_logic;
				      signal Pulse     :in  std_logic;
				      signal Rot       :in  std_logic ) is	
		begin
			--Reset to avoid test case dependence
			Reset(Test_case => Test_case,
			      Rst       => Rst,
			      Dir 	=> Dir,
			      Pulse   	=> Pulse,
			      Rot  	=> Rot );
			
			--Change state
			Test_case <= Test_1;	
			
			--Setup stimulus 0-------------------------------------------------------------
			wait_fclk(1);
			z <= '0';			--Set rotation input
			wait_fclk(1);
			z <= '1';			--Set rotation input
		
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(2);
			assert(Dir = '0')
			report "Output: Dir1 are not correct." severity error;
				
			assert(Pulse = '0')
			report "Output: Pulse1 are not correct." severity error;
				
			assert(Rot = '1')
			report "Output: Rot1 are not correct." severity error;
			
			wait_rclk(1);
			assert(Dir = '0')
			report "Output: Dir2 are not correct." severity error;
				
			assert(Pulse = '0')
			report "Output: Pulse2 are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot2 are not correct." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 2=====================================================================
			--Testing change in direction in mode 0
		procedure Test_input2(signal Test_case     :out State_machine;
									 signal Encoder_Ena   :out std_logic;
									 signal Encoder_CW    :out std_logic;
									 signal Rst           :out std_logic;
									 signal Mode          :out std_logic;
									 signal Z  		       :out std_logic;
									 signal Dir  		    :in  std_logic;
									 signal Pulse         :in  std_logic;
									 signal Rot   		    :in  std_logic ) is
		begin
			--Reset to avoid test case dependence
			Reset(Test_case => Test_case,
					Rst       => Rst,
					Dir 		 => Dir,
					Pulse   	 => Pulse,
					Rot  		 => Rot );
			
			--Change state
			Test_case <= Test_2;	
			
			--Setup stimulus 0-------------------------------------------------------------
			wait_rclk(1);
			Mode        <= '0';
			Encoder_Ena <= '1';					--Enable encoder
			Encoder_CW  <= '0';					--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';					--Set rotation input
				
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(6);
			
			for i in 0 to 1 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				
				for i in 0 to 2 loop
					wait_rclk(1);
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
						
					assert(Pulse = '0')
					report "Output: Pulse are not correct." severity error;
					
					assert(Rot = '0')
					report "Output: Rot are not correct." severity error;
				end loop;
				wait_rclk(1);
			end loop;
			
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '0';
			Encoder_Ena <= '1';			--Enable encoder
			Encoder_CW  <= '1';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Verifying response to stimulus 0---------------------------------------------
			for i in 0 to 2 loop
				wait_rclk(1);
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
			end loop;
			wait_rclk(1);
				
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Verifying response to stimulus 1---------------------------------------------
			for i in 0 to 4 loop
				wait_rclk(1);
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
				
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
			end loop;
			
			wait_rclk(1);
			for i in 0 to 1 loop
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				
				for i in 0 to 2 loop
					wait_rclk(1);
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
						
					assert(Pulse = '0')
					report "Output: Pulse are not correct." severity error;
					
					assert(Rot = '0')
					report "Output: Rot are not correct." severity error;
				end loop;
				wait_rclk(1);
			end loop;
			
			assert(Dir = '0')
			report "Output: Dir are not correct." severity error;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 2-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '0';
			Encoder_Ena <= '1';			--Enable encoder
			Encoder_CW  <= '0';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Verifying response to stimulus 1---------------------------------------------
			for i in 0 to 2 loop
				wait_rclk(1);
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
			end loop;
			wait_rclk(1);
				
			assert(Dir = '0')
			report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			wait_rclk(1);
			
			for i in 0 to 4 loop
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			--Setup stimulus 2-------------------------------------------------------------
			for i in 0 to 1 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				
				for i in 0 to 2 loop
					wait_rclk(1);
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
						
					assert(Pulse = '0')
					report "Output: Pulse are not correct." severity error;
					
					assert(Rot = '0')
					report "Output: Rot are not correct." severity error;
				end loop;
				wait_rclk(1);
			end loop;
			
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '0';
			Encoder_Ena <= '0';			--Enable encoder
			Encoder_CW  <= '0';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Setup stimulus 2-------------------------------------------------------------
			wait_rclk(1);
			for i in 0 to 2 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '0')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
				
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Verifying response to stimulus 2---------------------------------------------
			wait_rclk(1);
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '0')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 3=====================================================================
			--Testing the CWW encoder input in mode 1
		procedure Test_input3(signal Test_case     :out State_machine;
									 constant Encoder_Dir :in  std_logic;
									 signal Encoder_Ena   :out std_logic;
									 signal Encoder_CW    :out std_logic;
									 signal Rst           :out std_logic;
									 signal Mode          :out std_logic;
									 signal Z  		       :out std_logic;
									 signal Dir  		    :in  std_logic;
									 signal Pulse         :in  std_logic;
									 signal Rot   		    :in  std_logic ) is
		begin
			--Reset to avoid test case dependence
			Reset(Test_case => Test_case,
					Rst       => Rst,
					Dir 		 => Dir,
					Pulse   	 => Pulse,
					Rot  		 => Rot );
			
			--Change state
			Test_case <= Test_3;	
			
			--Setup stimulus 0-------------------------------------------------------------
			wait_rclk(1);
			Mode        <= '1';
			Encoder_Ena <= '1';					--Enable encoder
			Encoder_CW  <= Encoder_Dir;		--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';					--Set rotation input
				
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(4);
			
			for i in 0 to 9 loop
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '0';						--Enable encoder
			Encoder_CW  <= Encoder_Dir;			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';						--Set rotation input
			
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(1);
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Setup stimulus 2-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '1';						--Enable encoder
			Encoder_CW  <= Encoder_Dir;			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';						--Set rotation input
			
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(1);
			for i in 0 to 1 loop
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus 1---------------------------------------------
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '0')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			wait_rclk(1);
			
			--Verifying response to stimulus 2---------------------------------------------
			for i in 0 to 9 loop
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
				
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 3-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '0';						--Enable encoder
			Encoder_CW  <= Encoder_Dir;			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';						--Set rotation input
			
			--Verifying response to stimulus 3---------------------------------------------
			for i in 0 to 2 loop
				wait_rclk(1);
				if(Encoder_Dir = '0') then
					assert(Dir = '1')
					report "Output: Dir are not correct." severity error;
				else
					assert(Dir = '0')
					report "Output: Dir are not correct." severity error;
				end if;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
			end loop;
			wait_rclk(1);
				
			if(Encoder_Dir = '0') then
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
			else
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
			end if;
				
			assert(Pulse = '0')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Change state
			Test_case <= None;
		end procedure;
		
		--Procedure for test 4=====================================================================
			--Testing change in direction in mode 1
		procedure Test_input4(signal Test_case     :out State_machine;
									 signal Encoder_Ena   :out std_logic;
									 signal Encoder_CW    :out std_logic;
									 signal Rst           :out std_logic;
									 signal Mode          :out std_logic;
									 signal Z  		       :out std_logic;
									 signal Dir  		    :in  std_logic;
									 signal Pulse         :in  std_logic;
									 signal Rot   		    :in  std_logic ) is
		begin
			--Reset to avoid test case dependence
			Reset(Test_case => Test_case,
					Rst       => Rst,
					Dir 		 => Dir,
					Pulse   	 => Pulse,
					Rot  		 => Rot );
			
			--Change state
			Test_case <= Test_4;	
			
			--Setup stimulus 0-------------------------------------------------------------
			wait_rclk(1);
			Mode        <= '1';
			Encoder_Ena <= '1';					--Enable encoder
			Encoder_CW  <= '0';					--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';					--Set rotation input
				
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(4);
				
			for i in 0 to 5 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
				
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '1';			--Enable encoder
			Encoder_CW  <= '1';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Verifying response to stimulus 0---------------------------------------------
			wait_rclk(1);
			for i in 0 to 3 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
				
			--Verifying response to stimulus 1---------------------------------------------
			for i in 0 to 5 loop
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
				
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
					
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
				
			--Setup stimulus 2-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '1';			--Enable encoder
			Encoder_CW  <= '0';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Verifying response to stimulus 1---------------------------------------------
			wait_rclk(1);
			for i in 0 to 3 loop
				assert(Dir = '0')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus 2---------------------------------------------
			for i in 0 to 6 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
				
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
					
			assert(Pulse = '1')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;
			
			--Setup stimulus 1-------------------------------------------------------------
			wait_fclk(1);
			Mode        <= '1';
			Encoder_Ena <= '0';			--Enable encoder
			Encoder_CW  <= '1';			--Encoder Dir: 1=CW, 0=CWW
			z 				<= '1';			--Set rotation input
			
			--Verifying response to stimulus 2---------------------------------------------
			wait_rclk(1);
			for i in 0 to 2 loop
				assert(Dir = '1')
				report "Output: Dir are not correct." severity error;
					
				assert(Pulse = '1')
				report "Output: Pulse are not correct." severity error;
					
				assert(Rot = '0')
				report "Output: Rot are not correct." severity error;
				wait_rclk(1);
			end loop;
			
			--Verifying response to stimulus 3---------------------------------------------
			assert(Dir = '1')
			report "Output: Dir are not correct." severity error;
				
			assert(Pulse = '0')
			report "Output: Pulse are not correct." severity error;
				
			assert(Rot = '0')
			report "Output: Rot are not correct." severity error;

			Test_case <= None;
		end procedure;
		
	--Unit under test====================================================================================	
	begin   
		uut: Rotary_decoder
		port map( Clk   => Clk_sig,
					 Rst   => Rst_sig,
					 Mode  => Mode_sig,
					 A     => A_sig,
					 B     => B_sig,
					 Z     => Z_sig,
					 Dir   => Dir_sig,
					 Pulse => Pulse_sig,
					 Rot   => Rot_sig );
		
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
			wait for 10 ns;											--Startup time					
			
			--Mode 0 ---------------------------------------------------------------------------------------
			--Testing CWW Rotation
--			Test_input0(Test_case   => Test_case,
--						   Encoder_Ena => Encoder_Ena,
--							Encoder_Dir => '0',						-- '1'=CW, '0'=CWW
--						   Encoder_CW  => Encoder_CW,
--							Rst   	   => Rst_sig,
--							Mode        => Mode_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
							
			--Testing CW Rotation
--			Test_input0(Test_case   => Test_case,
--						   Encoder_Ena => Encoder_Ena,
--							Encoder_Dir => '1',						-- '1'=CW, '0'=CWW
--						   Encoder_CW  => Encoder_CW,
--							Rst   	   => Rst_sig,
--							Mode        => Mode_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
				
			--Testing change in direction
--			Test_input2(Test_case   => Test_case,
--						   Encoder_Ena => Encoder_Ena,
--						   Encoder_CW  => Encoder_CW,
--							Rst   	   => Rst_sig,
--							Mode        => Mode_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
				
			--Mode 1 ---------------------------------------------------------------------------------------
			--Testing CWW Rotation
			Test_input3(Test_case   => Test_case,
						   Encoder_Ena => Encoder_Ena,
							Encoder_Dir => '0',						-- '1'=CW, '0'=CWW
						   Encoder_CW  => Encoder_CW,
							Rst   	   => Rst_sig,
							Mode        => Mode_sig,
							Z  		   => Z_sig,
							Dir  		   => Dir_sig,
							Pulse       => Pulse_sig,
							Rot   	   => Rot_sig );
				
			--Testing CW Rotation
--			Test_input3(Test_case   => Test_case,
--						   Encoder_Ena => Encoder_Ena,
--							Encoder_Dir => '1',						-- '1'=CW, '0'=CWW
--						   Encoder_CW  => Encoder_CW,
--							Rst   	   => Rst_sig,
--							Mode        => Mode_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
				
			--Testing change in direction
--			Test_input4(Test_case   => Test_case,
--						   Encoder_Ena => Encoder_Ena,
--						   Encoder_CW  => Encoder_CW,
--							Rst   	   => Rst_sig,
--							Mode        => Mode_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
				
			--Other tests ----------------------------------------------------------------------------------
			--Testing Z pulse detection
--			Test_input1(Test_case   => Test_case,
--							Rst   	   => Rst_sig,
--							Z  		   => Z_sig,
--							Dir  		   => Dir_sig,
--							Pulse       => Pulse_sig,
--							Rot   	   => Rot_sig );
			
			--Reseting------------------
--			Reset(Test_case => Test_case,
--					Rst       => Rst_sig,
--					Dir 		 => Dir_sig,
--					Pulse   	 => Pulse_sig,
--					Rot  		 => Rot_sig );
			wait;
		end process;
		
		--Mimic Sensor====================================================================================  
		Encoder: process(Clk_sig, Rst_sig)
		begin 		
			if(Rst_sig = '0') then
				count <= (others => '0');
				A_sig <= '1';
				B_sig <= '1';
				
			elsif(falling_edge(Clk_sig) and (Encoder_Ena = '1')) then
				if(Encoder_CW = '1') then
					count <= count + 1;				--Set CW Dir
				else
					count <= count - 1;				--Set CCW Dir
				end if;							
					
				--Direction of Setp pulse
				if(count = 0) then
					A_sig <= '0';
					B_sig <= '0';
				elsif(count = 1) then
					A_sig <= '1';
					B_sig <= '0';
				elsif(count = 2) then
					A_sig <= '1';
					B_sig <= '1';
				else
					A_sig <= '0';
					B_sig <= '1';
				end if;
			end if;
		end process;
end Behavioral;
