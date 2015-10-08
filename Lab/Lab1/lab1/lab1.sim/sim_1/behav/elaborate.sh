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
ExecStep $xv_path/bin/xelab -wto 3674c76d0cfb48908cd7cb1dc1ef2e42 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot tb_mycounter_behav xil_defaultlib.tb_mycounter -log elaborate.log
