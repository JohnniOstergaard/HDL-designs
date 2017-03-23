--Description ===================================================================
--   Velocity and Acceleration Counter.
--Information ===================================================================
--   File name:      Vel_Acc.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:  VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.2        | Major.minor.patch
--   Created:        20-03-2017
--   Modified:       21-03-2017   | Bug fix: change Acc port length from Bit_width to Bit_width-1
--   Modified:       23-03-2017   | Bug fix: change eq for Acc and Vel
--===============================================================================

--Including----------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_signed.all;
	use ieee.numeric_std.all;
---------------------------------

entity Vel_Acc is
	generic( Bit_width :positive := 8 );									--Resolution in bits
	port( Clk    :in  std_logic;										--System clock
	      Rst    :in  std_logic;										--Reset logic
	      Pulse  :in  std_logic;										--Step pulse
	      Dir    :in  std_logic;										--Step direction
	      Mode   :in  std_logic;										--'0' = Normal, '1' = Predictive mode
	      Vel    :out std_logic_vector(Bit_width-1 downto 0) := ('0', others => '1');			--Velocity, unit: [Clk cycles/Pulse]
	      Acc    :out std_logic_vector(Bit_width-1 downto 0) := (others => '0') );				--Acceleration, unit: [delta (Clk cycles/Pulse)]
end Vel_Acc;

architecture Behavioral of Vel_Acc is
	Constant Maximum   :std_logic_vector(Bit_width-2 downto 0) := (others => '1');				--Max value base on "Bit_width" - generic
		
	signal Clk_count   :std_logic_vector(Bit_width-2 downto 0) := (others => '0');				--Clk edges between pulses
	signal Vel_sample  :std_logic_vector(Bit_width-1 downto 0) := ('0', others => '1');			--Firste Velocity sample as vector type
	signal Vel_sample2 :std_logic_vector(Bit_width-1 downto 0) := ('0', others => '1');			--Second Velocity sample as vector type
	signal Vel_Reg     :std_logic_vector(Bit_width-1 downto 0) := (others => '0');
	signal Pulse1_set  :std_logic := '0';
		
	begin
	process(Clk, Rst) is
		constant Maximum_int     :integer := to_integer(unsigned(Maximum));				--Maximum vector as integer type
		variable Vel_sample_int  :integer range -Maximum_int-1 to Maximum_int;				--Firste Velocity sample as integer type
		variable Vel_sample2_int :integer range -Maximum_int-1 to Maximum_int;				--Second Velocity sample as integer type
		
	begin
		if(Rst = '0') then
			Pulse1_set  <= '0';
			Clk_count   <= (others => '0');
			Acc         <= (others => '0');
			Vel	    <= ('0', others => '1');
			Vel_Reg	    <= (others => '0');
			Vel_sample  <= ('0', others => '1');
			Vel_sample2 <= ('0', others => '1');
			
		elsif rising_edge(Clk) then
			--Normal mode ===============================================================
			if(Pulse1_set = '1' and unsigned(Clk_count) = 0) then
				Vel_Reg <= (others => '0');
					
				--Vel -------------------------------------------------------------------
				Vel_sample_int  := to_integer(signed(Vel_sample));						--Converted vel_sample  to int
				Vel_sample2_int := to_integer(signed(Vel_sample2));						--Converted vel_sample2 to int
				Vel             <= Vel_sample;									--Set new Velocity
				
				--Acc -------------------------------------------------------------------
				if((Vel_sample >  0 and Vel_sample2 >  0) or 
				  ((Vel_sample >= 0 and Vel_sample2 >= 0) and Dir = '0' )) then
						
					Acc <= std_logic_vector(to_signed((Vel_sample2_int - Vel_sample_int),Acc'length));	--[1*] Set new Acceleration
					
				elsif((Vel_sample <  0 and Vel_sample2 <  0) or
				     ((Vel_sample <= 0 and Vel_sample2 <= 0) and Dir = '1' )) then
						
					Acc <= std_logic_vector(to_signed((Vel_sample_int - Vel_sample2_int),Acc'length));	--[2*] Set new Acceleration
					
				elsif(Vel_sample > 0 and Vel_sample2 < 0) then
					Acc <= std_logic_vector(to_signed(
					(
						(- Maximum_int - Vel_sample2_int) - (Maximum_int - Vel_sample_int)		--[3*] Set new Acceleration
					),Acc'length));	
					
				else
					Acc <= std_logic_vector(to_signed(
					(
						(Maximum_int + Vel_sample_int) - (Maximum_int - Vel_sample2_int)		--[4*] Set new Acceleration
					),Acc'length));	
				end if;
				
			--Predictive mode ==========================================================
			elsif(unsigned(Clk_count) > abs(Vel_sample_int) +1) then
				if(Mode = '1') then
					--Range limited-----------------------
					if(signed(Vel) >= Maximum_int -1) then
						Vel(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Clk_count));				--Set Predictive Velocity
							
						if(signed(Acc) > - Maximum_int) then
							Acc <= std_logic_vector(to_signed(Vel_sample_int,Acc'length) - signed(Vel) -1);		--Set Predictive Acceleration
						end if;
						
					elsif(signed(Vel) <= - (Maximum_int -1)) then	
						Vel(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Maximum) - unsigned(Clk_count)+1);	--Set Predictive Velocity
							
						if(signed(Vel) = - (Maximum_int -1)) then	
							Acc <= std_logic_vector(signed(Vel) - to_signed(Vel_sample_int,Acc'length) -1);		--Set Predictive Acceleration
						end if;
						
					--Inside range----------------------------------	
					elsif(Vel_sample >= 0 and Vel_sample2 >= 0 and Dir = '0') then
						Vel(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Clk_count) -1);				--Set Predictive Velocity
						Acc <= std_logic_vector(to_signed(Vel_sample_int,Acc'length) - signed(Vel) -1);			--Set Predictive Acceleration
						
					else	
						Vel(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Maximum) - unsigned(Clk_count)+2);	--Set Predictive Velocity
						Acc <= std_logic_vector(signed(Vel) - to_signed(Vel_sample_int,Acc'length) -1);			--Set Predictive Acceleration
						Vel(Bit_width-1) <= Dir;
					end if;
					
				--Normal mode range limited ==============================================	
				elsif(unsigned(Clk_count) = Maximum_int) then
					if(Dir = '0') then
						Vel_Reg(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Clk_count));
					else
						Vel_Reg(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Maximum) - unsigned(Clk_count)+1);
					end if;
					Vel_Reg(Bit_width-1) <= Dir;
					Vel                  <= Vel_Reg;
					
					if(signed(Vel_Reg) = Maximum_int) then
						Acc <= std_logic_vector(to_signed(Vel_sample_int,Acc'length) - signed(Vel_Reg));
						
					elsif(signed(Vel_Reg) = - (Maximum_int)) then	
						Acc <= std_logic_vector(signed(Vel_Reg) - to_signed(Vel_sample_int,Acc'length));
					end if;
				end if;
			end if;
			
			--Clock edge Counter ========================================================
			if(Pulse = '1') then
				Pulse1_set    <= '1';												--The first pulse input
				Vel_sample2   <= Vel_sample;											--Set vel_sample2 value
				Clk_count     <= (others => '0');										--Reset clk counter
				
				--Set direction for Velocity sample	
				if(Dir = '1' and unsigned(Clk_count) = 0) then
					Vel_sample(Bit_width-1) <= '0';										--MSb = '0', B"1000_0000" = -128 not 0
				else
					Vel_sample(Bit_width-1) <= Dir;										--MSb = Dir
				end if;
				
				--Set value for Velocity sample	
				if(Dir = '0') then
					Vel_sample(Bit_width-2 downto 0) <= Clk_count;								--Set vel_sample value
				else
					Vel_sample(Bit_width-2 downto 0) <= std_logic_vector(unsigned(Maximum(Bit_width-2 downto 0))+1 - unsigned(Clk_count));
				end if;
				
			elsif(unsigned(Clk_count) < unsigned(Maximum)) then
				Clk_count <= Clk_count + '1';											--Count clks between pulse
			end if;
		end if;
	end process;
end Behavioral;

--Notes ===============================================================================================================================
	
	--============================================	
	--1* 8bit-Example: range (-12 < 0 and -5 < O)
	--============================================
	--	        -12  -5  0   
	--  -127|<--------|###|--|------------>|+127
	--		    x
	-- Eq:
	-- ( -5 to -12) => x = (-12)-(-5) =-7
	-- (-12 to  -5) => x = (-5)-(-12) = 7
	--============================================	
	
	
	--============================================
	--2* 8bit-Example: range (+5 > 0 and +12 > O)
	--============================================
	--	  	       0   +5  +12
	--  -127|<-------------|----|###|----->|+127
	--			      x
	-- Eq:
	-- ( 5 to 12) => x =(+12)-(+5) =  7
	-- (12 to  5) => x =(+5)-(+12) = -7
	--============================================
	
	
	--=====================================================
	--3*/4* 8bit-Example: range (-12 < 0 and +5 > O)
	--=====================================================
	--	  	 -12	0   +5
	--  -127|<--------|-----|----|-------->|+127
	--	|#########|	     |#########|
	--	   -115			 122
	--
	-- 3* Eq:  ( +5 to -12) => [-127-(-12)] - [+127-5] =-7
	-- 4* Eq:  (-12 to  +5) => [+127-5] - [-127-(-12)] = 7 
	--=====================================================
