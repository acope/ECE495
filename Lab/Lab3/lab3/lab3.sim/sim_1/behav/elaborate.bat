@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto 6dd5183cbbae4d4d82b82930dfdfb805 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tb_cordic_fp_behav xil_defaultlib.tb_cordic_fp -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
