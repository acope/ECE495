@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xsim tb_cordic_fp_behav -key {Behavioral:sim_1:Functional:tb_cordic_fp} -tclbatch tb_cordic_fp.tcl -view C:/Users/mr_co_000/Documents/GitHub/ECE495/Homework/Homework4/homework4/tb_cordic_fp_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0