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
ExecStep $xv_path/bin/xsim tb_mycounter_behav -key {Behavioral:sim_1:Functional:tb_mycounter} -tclbatch tb_mycounter.tcl -log simulate.log
