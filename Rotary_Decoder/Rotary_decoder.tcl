#Description ===================================================================
#   Test script for the TB_Rotary_decoder testbench.
#Information ===================================================================
#   File name:      Rotary_decoder.Tcl
#   Target file:    TB_Rotary_decoder.VHDL
#   Engineer:       Johnni Østergaard
#   Copyright:      (c) 2017 Johnni Østergaard
#   Credits:         
#   License:        MIT License
#   Interpreter:    ModelSim Altera starter edition 10.4d
#Progress ======================================================================
#   Status:         Development
#   Version:        1.0.0        | Major.minor.patch
#   Created:        04.01.2017
#   Modified:       04-01-2017   | 
#===============================================================================

#Delet old library files
if {[file exists work]} then {vdel -lib work -all}

#Waveforms-----(Colors: green, cyan, orange, yellow or orchid)--------------------
add wave -divider Controls
add wave -color green	-binary 	-position insertpoint \sim:/TB_Rotary_decoder/uut/Clk
add wave -color green	-binary 	-position insertpoint \sim:/TB_Rotary_decoder/uut/Rst
add wave -color green	-binary 	-position insertpoint \sim:/TB_Rotary_decoder/uut/Mode

add wave -divider Signals
add wave -color orchid 	-binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Sensor
add wave -color orchid 	-binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Past
#add wave -color orchid -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Rotary_Q1
#add wave -color orchid -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Rotary_Q2
#add wave -color orchid -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Rotary_Q1_Reg
#add wave -color orchid -Unsigned	-position insertpoint \sim:/TB_Rotary_decoder/uut/Z_Reg
#add wave -color orchid -Unsigned	-position insertpoint \sim:/TB_Rotary_decoder/uut/Rot_temp
	
add wave -divider Inputs
add wave -color cyan 	-binary   	-position insertpoint \sim:/TB_Rotary_decoder/uut/A
add wave -color cyan 	-binary   	-position insertpoint \sim:/TB_Rotary_decoder/uut/B
add wave -color cyan 	-binary   	-position insertpoint \sim:/TB_Rotary_decoder/uut/Z

add wave -divider Outputs	
add wave -color orange  -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Dir 
add wave -color orange  -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Pulse
add wave -color orange  -binary		-position insertpoint \sim:/TB_Rotary_decoder/uut/Rot

add wave -divider Test_bench
add wave -color yellow              	-position insertpoint \sim:/TB_Rotary_decoder/Test_case

#Simulation time/window-----(Time units: ms, us, ns)-------------------------------
run 50us
wave zoom range 0ns 10000ns
