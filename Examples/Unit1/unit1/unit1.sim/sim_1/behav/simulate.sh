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
ExecStep $xv_path/bin/xsim tb_mybcd_udcount_behav -key {Behavioral:sim_1:Functional:tb_mybcd_udcount} -tclbatch tb_mybcd_udcount.tcl -log simulate.log
