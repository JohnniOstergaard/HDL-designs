--Description ===================================================================
--   Quadrature Incremental Rotary Decoder with both Pulse detecting mode and
--   Edge detecting mode.
--Information ===================================================================
--   File name:      Rotary_decoder.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:	VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.0        | Major.minor.patch
--   Created:        04.01.2017
--   Modified:       04-01-2017   | Base functionality validted in testbench
--===============================================================================

--Including------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-----------------------------------

entity Rotary_decoder is	
	port( Clk   :in  std_logic;							--System clock
			Rst   :in  std_logic;							--Reset logic
			Mode  :in  std_logic;							--0=Pulse detecting mode, 1=Edge detecting mode
			A     :in  std_logic; 							--A-phase of the Quadrature signal, (Active low)
			B     :in  std_logic;							--B-phase of the Quadrature signal,	(Active low)
			Z     :in  std_logic; 							--Z-phase tricker one per rotation, (Active low)
			Dir   :out std_logic := '0'; 					--Direction of rotation detection
			Pulse :out std_logic := '0';					--Quadrature Pulse detection
			Rot   :out std_logic := '0' );				--Rotation Pulse detection
end Rotary_decoder;

architecture Behavioral of Rotary_decoder is	
	signal Sensor	 		:std_logic_vector(1 downto 0) := (others => '1');
	signal Past 	 		:std_logic_vector(1 downto 0) := (others => '1');
	signal Rotary_Q1 		:std_logic := '0'; 
	signal Rotary_Q1_Reg :std_logic := '0'; 
	signal Rotary_Q2 		:std_logic := '0'; 
	signal Z_Reg			:std_logic := '0';
	signal Rot_temp 		:std_logic := '0';
		
	begin 
	process(Clk, Rst)
	begin 
		if(Rst = '0') then
			Dir 				 <= '0';
			Pulse   			 <= '0';
			Rot  				 <= '0';
			Sensor 			 <= (others => '1');
			Past 		 		 <= (others => '1');
			Rotary_Q1		 <= '0';
			Rotary_Q1_Reg   <= '0';
			Rotary_Q2 		 <= '0';
			Z_Reg				 <= '0';
			Rot_temp			 <= '0';
			
		elsif(rising_edge(Clk)) then
			Sensor <= (A & B);									--Latch Quadrature inputs
			
			--Rotary Contact chatter Filter=======================================
			case Sensor is
				when "11" => Rotary_Q1 <= '0';
								 Rotary_Q2 <= Rotary_Q2;
						
				when "10" => Rotary_Q1 <= Rotary_Q1;
								 Rotary_Q2 <= '0';
						
				when "01" => Rotary_Q1 <= Rotary_Q1;
								 Rotary_Q2 <= '1';
						
				when "00" => Rotary_Q1 <= '1';
								 Rotary_Q2 <= Rotary_Q2;
						
				when others => Rotary_Q1 <= Rotary_Q1;
									Rotary_Q2 <= Rotary_Q2;
			end case;
				
			--Pulse detecting mode================================================
			if(Mode = '0') then 	
				--Direction and Pulse detection
				Rotary_Q1_Reg <= Rotary_Q1;
				if((Rotary_Q1 = '0') and (Rotary_Q1_Reg = '1')) then
					Pulse <= '1';
					Dir   <= Rotary_Q2;
				else
					Pulse <= '0';
					Dir   <= Dir;
				end if;
				
			--Edge detecting mode==================================================
			else		
				--Direction and Pulse detection
				case(Sensor) is	
					when B"11" =>
						past  <= B"11";										--Set current state	
							
						if(Past = B"01") then
							Dir   <= '1';										--Set direction of rotation
						elsif(Past = B"10") then	
							Dir   <= '0';										--Set direction of rotation
						end if;
							
						if(Past /= B"11") then
							Pulse <= '1';										--Set step Pulse	
						else
							Pulse <= '0';										--Stop Step pulse
						end if;
						
					when B"10" =>
						past  <= B"10";										--Set current state
							
						if(Past = B"11") then	
							Dir   <= '1';										--Set direction of rotation
						elsif(Past = B"00") then	
							Dir   <= '0';										--Set direction of rotation
						end if;
							
						if(Past /= B"10") then
							Pulse <= '1';										--Set step Pulse	
						else
							Pulse <= '0';										--Stop Step pulse
						end if;
						
					when B"00" =>
						past  <= B"00";										--Set current state
							
						if(Past = B"10") then
							Dir   <= '1';										--Set direction of rotation
						elsif(Past = B"01") then
							Dir   <= '0';										--Set direction of rotation
						end if;
							
						if(Past /= B"00") then
							Pulse <= '1';										--Set step Pulse	
						else
							Pulse <= '0';										--Stop Step pulse
						end if;
						
					when B"01" =>
						past  <= B"01";										--Set current state
							
						if(Past = B"00") then
							Dir   <= '1';										--Set direction of rotation
						elsif(Past = B"11") then
							Dir   <= '0';										--Set direction of rotation
						end if;
							
						if(Past /= B"01") then
							Pulse <= '1';										--Set step Pulse	
						else
							Pulse <= '0';										--Stop Step pulse
						end if;
						
					when others => Pulse <= '0';							--Stop Step pulse
				end case;
			end if;
				
			--Rotation detection==================================================
			Z_Reg <= Z;
			if((Z = '0') and (Z_Reg = '1')) then
				Rot_temp <= '1';
			else
				Rot_temp <= '0';
			end if;
			Rot <= Rot_temp;
		end if;
	end process;
end Behavioral;