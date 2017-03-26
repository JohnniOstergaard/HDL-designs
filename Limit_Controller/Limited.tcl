#Description ===================================================================
#   Test script for the TB_Limited testbench.
#Information ===================================================================
#   File name:      Limited.tcl
# 	Target file:	  TB_Limited.VHDL
#   Engineer:       Johnni Østergaard
#   Copyright:      (c) 2017 Johnni Østergaard
#   Credits:         
#   License:        MIT License
#   Interpreter:    ModelSim Altera starter edition 10.4d
#Progress ======================================================================
#   Status:         Development
#   Version:        1.0.0        | Major.minor.patch
#   Created:        13.10.2016
#   Modified:       26-03-2017   | Added the Pre_dir signal
#===============================================================================

#Delet old library files
if {[file exists work]} then {vdel -lib work -all}

#Signals-----(Colors: green, cyan, orange, yellow or orchid)--------------------	
add wave -divider Controls
add wave -color green	  -binary 	-position insertpoint \sim:/TB_Limited/uut/Clk
add wave -color green	  -binary 	-position insertpoint \sim:/TB_Limited/uut/Rst

add wave -divider Inputs
add wave -color cyan 	  -binary		-position insertpoint \sim:/TB_Limited/uut/Max
add wave -color cyan 	  -binary		-position insertpoint \sim:/TB_Limited/uut/Min
add wave -color cyan 	  -binary		-position insertpoint \sim:/TB_Limited/uut/Pre_dir
add wave -color cyan	  -binary		-position insertpoint \sim:/TB_Limited/uut/Dir
add wave -color cyan	  -unsigned	-position insertpoint \sim:/TB_Limited/uut/Duty

add wave -divider Outputs
add wave -color orange  -binary		-position insertpoint \sim:/TB_Limited/uut/Q_Dir
add wave -color orange	-unsigned	-position insertpoint \sim:/TB_Limited/uut/Q_Duty

add wave -divider Test_bench
add wave -color yellow            -position insertpoint \sim:/TB_Limited/Test_case

#Simulation time/window-----(Time units: ms, us, ns)-------------------------------
run 1000ns
wave zoom range 0ns 850ns
