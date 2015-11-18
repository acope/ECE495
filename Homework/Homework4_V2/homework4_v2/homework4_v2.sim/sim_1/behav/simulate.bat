@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xsim pipe_tb_behav -key {Behavioral:sim_1:Functional:pipe_tb} -tclbatch pipe_tb.tcl -view C:/Users/mr_co_000/Documents/GitHub/ECE495/Homework/Homework4_V2/homework4_v2/pipe_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
