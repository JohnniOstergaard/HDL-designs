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
> ![Dir_and_Duty_Test0](Images/Test0_Dir_and_Duty_RTL_view.png "Dir & Duty Test0")
>
> =============================================================================<br>
> **==============================[Min endstop Test]================================**<br>
> =============================================================================<br>
> **Test 1:**<br>
> Case 0 | Testing Min endstop with different test vectors.
> ![Min_endstop_Test1](Images/Test1_Min_endstop_RTL_view.png "Min endstop Test1")
> =============================================================================<br>
> **==============================[Max endstop Test]===============================**<br>
> =============================================================================<br>
> **Test 2:**<br>
> Case 0 | Testing Max endstop with different test vectors.
> ![Max_endstop_Test2](Images/Test2_Max_endstop_RTL_view.png "Max endstop Test2")
