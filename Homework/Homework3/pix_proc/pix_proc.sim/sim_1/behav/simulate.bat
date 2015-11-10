@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xsim atb_test_behav -key {Behavioral:sim_1:Functional:atb_test} -tclbatch atb_test.tcl -view C:/Users/mr_co_000/Documents/GitHub/ECE495/Homework/Homework3/pix_proc/atb_test_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
