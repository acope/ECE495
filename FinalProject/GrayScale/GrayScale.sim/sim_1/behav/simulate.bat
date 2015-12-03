@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xsim tb_grayscaletop_behav -key {Behavioral:sim_1:Functional:tb_grayscaletop} -tclbatch tb_grayscaletop.tcl -view C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/tb_my_mult_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
