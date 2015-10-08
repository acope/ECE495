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
ExecStep $xv_path/bin/xelab -wto 92186bb748264cc3969fc579135d3694 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot tb_serial_mult_behav xil_defaultlib.tb_serial_mult -log elaborate.log
