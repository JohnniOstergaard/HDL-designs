#Info-----------------------------------------------------------------------------
# File name:		Vel_Acc.tcl
# Target file:		TB_Vel_Acc.VHDL
# Description: 	Test script for the Vel_Acc testbench.
#
# Tool versions:	ModelSim Altera starter edition 10.4d
# Engineer:			Johnni Østergaard
# Create date: 	04.01.2017
# Revision:			1.00 - Base functionality validted in testbench
#---------------------------------------------------------------------------------

#Delet old library files
if {[file exists work]} then {vdel -lib work -all}

#Waveforms-----(Colors: green, cyan, orange, yellow or orchid)--------------------	
add wave -divider Controls
add wave -color green	-binary 		-position insertpoint \sim:/TB_Vel_Acc/uut/Clk
add wave -color green	-binary 		-position insertpoint \sim:/TB_Vel_Acc/uut/Rst

add wave -divider Signals
add wave -color orchid 	-Unsigned	-position insertpoint \sim:/TB_Vel_Acc/uut/Clk_count
add wave -color orchid 	-decimal		-position insertpoint \sim:/TB_Vel_Acc/uut/Vel_sample
add wave -color orchid 	-decimal		-position insertpoint \sim:/TB_Vel_Acc/uut/Vel_sample2
add wave -color orchid 	-binary		-position insertpoint \sim:/TB_Vel_Acc/uut/Pulse1_set
	
add wave -divider Inputs
add wave -color cyan 	-binary		-position insertpoint \sim:/TB_Vel_Acc/uut/Pulse
add wave -color cyan		-binary		-position insertpoint \sim:/TB_Vel_Acc/uut/Dir
add wave -color cyan		-binary		-position insertpoint \sim:/TB_Vel_Acc/uut/Mode

add wave -divider Outputs
add wave -color orange  -decimal		-position insertpoint \sim:/TB_Vel_Acc/uut/Vel 
add wave -color orange  -decimal		-position insertpoint \sim:/TB_Vel_Acc/uut/Acc 

add wave -divider Test_bench
add wave -color yellow              -position insertpoint \sim:/TB_Vel_Acc/Test_case

#Simulation time/window-----(Time units: ms, us, ns)-------------------------------
run 1500us
wave zoom range 0ns 800ns