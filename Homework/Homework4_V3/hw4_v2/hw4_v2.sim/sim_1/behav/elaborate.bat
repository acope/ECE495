@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto cdef7005dfde48f2908e87215d57a821 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot pipe_tb_text_behav xil_defaultlib.pipe_tb_text -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
