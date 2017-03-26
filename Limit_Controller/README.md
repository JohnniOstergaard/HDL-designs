# Limited
This design is a end stop limited based on the direction output from an controller.<br>

  ## Generics
  > **Bit_width:** (positive)<br> Allows easy scaling of the Port length of the Duty and Q_Duty ports and set the length of the counter by defining the number of bits in each port.<br>
  
  ## IO Ports
  > **Clk:** (std_logic)<br>   Clock port<br>
  > 
  > **Rst:** (std_logic)<br>   Asynchronous reset of design<br>
  > 
  > **Max:** (std_logic)<br>   End stop at maximum position <br> 
  > 
  > **Min:** (std_logic)<br>   End stop at minimum position <br> 
  > 
  > **Pre_dir:** (std_logic)<br>        Preset direction <br> 
  >
  > **Dir:** (std_logic)<br>            Direction input <br> 
  >
  > **Duty:** (std_logic_vector)<br>    Strength  input <br> 
  >
  > **Q_Dir:** (std_logic)<br>          Direction output response <br> 
  >
  > **Q_Duty:** (std_logic_vector)<br>  Strength  output response <br> 
 
  ## RTL simulations & verification
  These simulations are executed and tested with a self-checking modular testbench (TB_Limited.vhd) and
  The RTL trace view shown in the images below is setup with a tcl file (Limited.tcl).

> =============================================================================<br>
> **==============================[Dir and Duty Test]================================**<br>
> =============================================================================<br>
> **Test 0:**<br>
> Case 0 | Testing the direction and Duty ports.
> ![Vel_Acc_Test0_Dir0_Mode0](Image/Test0_Dir0_Mode0_RTL_view.png "Vel_Acc Test0, Dir='0',Mode='0'")
>
> =============================================================================<br>
> **==================================[Min endstop Test]=============================**<br>
> =============================================================================<br>
> **Test 1:**<br>
> Case 0 | Testing Min endstop with different test vectors.
> ![Vel_Acc_Test1_Dir0_Mode0](Image/Test1_Dir0_Mode0_RTL_view.png "Vel_Acc Test1, Dir='0',Mode='0'")
> =============================================================================<br>
>> **==================================[Max endstop Test]=============================**<br>
> =============================================================================<br>
> **Test 2:**<br>
> Case 0 | Testing Max endstop with different test vectors.
> ![Vel_Acc_Test2_Dir0_Mode0](Image/Test2_Dir0_Mode0_RTL_view.png "Vel_Acc Test2, Dir='0',Mode='0'")
