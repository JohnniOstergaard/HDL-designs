--Description ===================================================================
--   End stop limited.
--Information ===================================================================
--   File name:      Limited.VHDL
--   Engineer:       Johnni Østergaard
--   Copyright:      (c) 2017 Johnni Østergaard
--   Credits:         
--   License:        MIT License
--   Compatibility:  VHDL-2008
--Progress ======================================================================
--   Status:         Development
--   Version:        1.0.0        | Major.minor.patch
--   Created:        13-10-2016
--   Modified:       26-03-2017   | Updated the information text
--===============================================================================

--Including------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
-----------------------------------

entity Limited is
	generic( Bit_width :positive := 8 );																--Channel width in bits
	port( Clk     :in  std_logic;																			--System clock
	      Rst     :in  std_logic;																			--Reset logic
	      Max     :in  std_logic;																			--End stop at maximum position 
	      Min     :in  std_logic;																			--End stop at minimum position 
	      Pre_dir :in  std_logic;																			--Preset direction
	      Dir     :in  std_logic;																			--Direction input
	      Duty    :in  std_logic_vector(Bit_width-1 downto 0);									--Strength  input
	      Q_Dir   :out std_logic := '0';																--Direction output response 
	      Q_Duty  :out std_logic_vector(Bit_width-1 downto 0) := (others => '0') );		--Strength  output response 
end Limited;

architecture Behavioral of Limited is	
	begin
	process(Clk, Rst) is
		begin
		if(Rst = '0') then
			Q_Dir  <= '0';
			Q_Duty <= (others => '0');
			
		elsif rising_edge(Clk) then
			Q_Dir  <= Dir;
			if((Max = '0') and (Dir = Pre_dir)) then
				Q_Duty <= (others => '0');									--Set response strength to zero
			elsif((Min = '0') and (Dir = not Pre_dir)) then
				Q_Duty <= (others => '0');									--Set response strength to zero
			else
				Q_Duty <= Duty;												--Set duty to the rest of the Re vector
			end if;
		end if;
	end process;
end Behavioral;
