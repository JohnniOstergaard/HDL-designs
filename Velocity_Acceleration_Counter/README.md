# Vel_Acc_Counter
  Counting velocity and acceleration as clock cycles in between pulse.

  **Generic:**<br>
  Allows easy scaling of the Port length for the Vel and Acc ports.
  But the testbench is not ready for scaling do to the static values used to compare outputs with!<br>
  
  **Clk Port:**<br>
  std_logic | Clock port<br>
  
  **Rst Port:**<br>
  std_logic | Asynchronous reset of design<br>
  
  **Pulse Port:**<br>  
  std_logic | Encoder step pulse<br> 
  
  **Dir Port:**<br>  
  std_logic | Encoder direction<br>
  
  **Mode Port:**<br>  
  std_logic | The normal mode is updating the (Vel) and (Acc) output ports when a pulse occurs on the input port (Pulse).
  The Predictive mode takes it one step further and update the (Vel) and (Acc) output ports in between inputs from the (pulse) port when   decreasing acceleration occurs this means a faster response when suddenly going from a high to a lower velocity.<br>
  
  **Vel Port:**<br>  
  std_logic_vector | encoded with a sign value where minus values is velocity in the counterclockwise direction and a plus values is       velocity in the clockwise direction. [Number of Clock periods between pulses]<br>
  
  **Acc Port:**<br> 
  std_logic_vector | encoded with a sign value where minus values is a decreasing acceleration and a plus values is an increasing         acceleration. [Velocity delta between pulses]<br>

## RTL simulations of Vel_Acc.vhd
  These simulations are executed and tested with a self-checking modular testbench (TB_Vel_Acc.vhd) and
  The RTL trace view shown in the images below is setup with a tcl file (Vel_Acc.tcl).

> =============================================================================<br>
> **============================[Constant Velocity Test]=============================**<br>
> =============================================================================<br>
> **Test 0:**<br>
> Case 0 | Testing constant clockwise velocity in normal mode.
> ![Vel_Acc_Test0_Dir0_Mode0](Image/Test0_Dir0_Mode0_RTL_view.png "Vel_Acc Test0, Dir='0',Mode='0'")
>
> Case 1 | Testing constant counterclockwise velocity in normal mode.
> ![Vel_Acc_Test0_Dir1_Mode0](Image/Test0_Dir1_Mode0_RTL_view.png "Vel_Acc Test0, Dir='1',Mode='0'")
>
> Case 2 | Testing constant clockwise velocity in predictive mode.
> ![Vel_Acc_Test0_Dir0_Mode1](Image/Test0_Dir0_Mode1_RTL_view.png "Vel_Acc Test0, Dir='0',Mode='1'")
>
> Case 3 | Testing constant counterclockwise velocity in predictive mode.
> ![Vel_Acc_Test0_Dir1_Mode1](Image/Test0_Dir1_Mode1_RTL_view.png "Vel_Acc Test0, Dir='1',Mode='1'")
>
> =============================================================================<br>
> **============================[Increasing Acceleration Test]=======================**<br>
> =============================================================================<br>
> **Test 1:**<br>
> Case 0 | Testing increasing clockwise acceleration in normal mode.
> ![Vel_Acc_Test1_Dir0_Mode0](Image/Test1_Dir0_Mode0_RTL_view.png "Vel_Acc Test1, Dir='0',Mode='0'")
>
> Case 1 | Testing increasing counterclockwise acceleration in normal mode.
> ![Vel_Acc_Test1_Dir1_Mode0](Image/Test1_Dir1_Mode0_RTL_view.png "Vel_Acc Test1, Dir='1',Mode='0'")
>
> Case 2 | Testing increasing clockwise acceleration in predictive mode.
> ![Vel_Acc_Test1_Dir0_Mode1](Image/Test1_Dir0_Mode1_RTL_view.png "Vel_Acc Test1, Dir='0',Mode='1'")
>
> Case 3 | Testing increasing counterclockwise acceleration in predictive mode.
> ![Vel_Acc_Test1_Dir1_Mode1](Image/Test1_Dir1_Mode1_RTL_view.png "Vel_Acc Test1, Dir='1',Mode='1'")
>
> =============================================================================<br>
> **============================[Decreasing Acceleration Test]=======================**<br>
> =============================================================================<br>
> **Test 2:**<br>
> Case 0 | Testing decreasing clockwise acceleration in normal mode.
> ![Vel_Acc_Test2_Dir0_Mode0](Image/Test2_Dir0_Mode0_RTL_view.png "Vel_Acc Test2, Dir='0',Mode='0'")
>
> Case 1 | Testing decreasing counterclockwise acceleration in normal mode.
> ![Vel_Acc_Test2_Dir1_Mode0](Image/Test2_Dir1_Mode0_RTL_view.png "Vel_Acc Test2, Dir='1',Mode='0'")
>
> Case 2 | Testing decreasing clockwise acceleration in predictive mode.
> ![Vel_Acc_Test2_Dir0_Mode1](Image/Test2_Dir0_Mode1_RTL_view.png "Vel_Acc Test2, Dir='0',Mode='1'")
>
> Case 3 | Testing decreasing counterclockwise acceleration in predictive mode.
> ![Vel_Acc_Test2_Dir1_Mode1](Image/Test2_Dir1_Mode1_RTL_view.png "Vel_Acc Test2, Dir='1',Mode='1'")
