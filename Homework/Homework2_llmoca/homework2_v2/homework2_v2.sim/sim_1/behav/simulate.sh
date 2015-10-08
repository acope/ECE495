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
ExecStep $xv_path/bin/xsim tb_serial_mult_behav -key {Behavioral:sim_1:Functional:tb_serial_mult} -tclbatch tb_serial_mult.tcl -log simulate.log
