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
ExecStep $xv_path/bin/xelab -wto 3674c76d0cfb48908cd7cb1dc1ef2e42 -m64 --debug typical --relax --mt 8 --maxdelay -L xil_defaultlib -L simprims_ver -L secureip --snapshot tb_mycounter_time_impl -transport_int_delays -pulse_r 0 -pulse_int_r 0 xil_defaultlib.tb_mycounter xil_defaultlib.glbl -log elaborate.log
