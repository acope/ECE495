#!/bin/sh -f
xv_path="/opt/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto e692dfacead345f78e069e4ae91f5e1d -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot tb_mybcd_udcount_behav xil_defaultlib.tb_mybcd_udcount -log elaborate.log
