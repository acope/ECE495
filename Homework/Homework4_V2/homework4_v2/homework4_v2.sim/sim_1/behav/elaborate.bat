@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto 30e52cfa0c1448e18fce95db07aab79e -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot pipe_tb_behav xil_defaultlib.pipe_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
