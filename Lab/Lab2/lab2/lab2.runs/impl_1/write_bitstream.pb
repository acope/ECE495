
q
Command: %s
1870*	planAhead2?
+open_checkpoint design_1_wrapper_routed.dcp2default:defaultZ12-2866h px
c
-Analyzing %s Unisim elements for replacement
17*netlist2
182default:defaultZ29-17h px
g
2Unisim Transformation completed in %s CPU seconds
28*netlist2
02default:defaultZ29-28h px
u
Netlist was created with %s %s291*project2
Vivado2default:default2
2015.22default:defaultZ1-479h px
S
Loading part %s157*device2#
xc7z010clg400-12default:defaultZ21-403h px
H
)Preparing netlist for logic optimization
349*projectZ1-570h px
�
Parsing XDC File [%s]
179*designutils2�
{/home/akcopema/Documents/ECE495/Lab/Lab2/lab2/lab2.runs/impl_1/.Xil/Vivado-28683-EC464ubuntu/dcp/design_1_wrapper_early.xdc2default:defaultZ20-179h px
�
Finished Parsing XDC File [%s]
178*designutils2�
{/home/akcopema/Documents/ECE495/Lab/Lab2/lab2/lab2.runs/impl_1/.Xil/Vivado-28683-EC464ubuntu/dcp/design_1_wrapper_early.xdc2default:defaultZ20-178h px
<
Reading XDEF placement.
206*designutilsZ20-206h px
A
Reading placer database...
1602*designutilsZ20-1892h px
:
Reading XDEF routing.
207*designutilsZ20-207h px
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2$
Read XDEF File: 2default:default2
00:00:00.172default:default2
00:00:00.192default:default2
1173.7542default:default2
2.0002default:default2
23242default:default2
126742default:defaultZ17-722h px
�
7Restored from archive | CPU: %s secs | Memory: %s MB |
1612*designutils2
0.1700002default:default2
1.1672362default:defaultZ20-1924h px
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common20
Finished XDEF File Restore: 2default:default2
00:00:00.172default:default2
00:00:00.192default:default2
1173.7542default:default2
2.0002default:default2
23242default:default2
126742default:defaultZ17-722h px
{
!Unisim Transformation Summary:
%s111*project29
%No Unisim elements were transformed.
2default:defaultZ1-111h px
`
$Checkpoint was created with build %s293*project2
12668562default:defaultZ1-484h px
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2"
Implementation2default:default2
xc7z0102default:defaultZ17-347h px
�
0Got license for feature '%s' and/or device '%s'
310*common2"
Implementation2default:default2
xc7z0102default:defaultZ17-349h px
u
,Running DRC as a precondition to command %s
1349*	planAhead2#
write_bitstream2default:defaultZ12-1349h px
M
Running DRC with %s threads
24*drc2
82default:defaultZ23-27h px
�
Rule violation (%s) %s - %s
20*drc2
NSTD-12default:default2,
Unspecified I/O Standard2default:default2�
�4 out of 134 logical ports use I/O standard (IOSTANDARD) value 'DEFAULT', instead of a user assigned specific value. This may cause I/O contention or incompatibility with the board power or connectivity affecting performance, signal integrity or in extreme cases cause damage to the device or the components to which it is connected. To correct this violation, specify all I/O standards. This design will fail to generate a bitstream unless all logical ports have a user specified I/O standard value defined. To allow bitstream creation with unspecified I/O standard values (not recommended), use this command: set_property SEVERITY {Warning} [get_drc_checks NSTD-1].  NOTE: When using the Vivado Runs infrastructure (e.g. launch_runs Tcl command), add this command to a .tcl file and add that file as a pre-hook for write_bitstream step for the implementation run. Problem ports: led_4bits_tri_o[3:0].2default:defaultZ23-20h px
�
Rule violation (%s) %s - %s
20*drc2
UCIO-12default:default2.
Unconstrained Logical Port2default:default2�
�4 out of 134 logical ports have no user assigned specific location constraint (LOC). This may cause I/O contention or incompatibility with the board power or connectivity affecting performance, signal integrity or in extreme cases cause damage to the device or the components to which it is connected. To correct this violation, specify all pin locations. This design will fail to generate a bitstream unless all logical ports have a user specified site LOC constraint defined.  To allow bitstream creation with unspecified pin locations (not recommended), use this command: set_property SEVERITY {Warning} [get_drc_checks UCIO-1].  NOTE: When using the Vivado Runs infrastructure (e.g. launch_runs Tcl command), add this command to a .tcl file and add that file as a pre-hook for write_bitstream step for the implementation run.  Problem ports: led_4bits_tri_o[3:0].2default:defaultZ23-20h px
W
DRC finished with %s
1905*	planAhead2
2 Errors2default:defaultZ12-3199h px
f
BPlease refer to the DRC report (report_drc) for more information.
1906*	planAheadZ12-3200h px
O
+Error(s) found during DRC. Bitgen not run.
1345*	planAheadZ12-1345h px
W
Releasing license: %s
83*common2"
Implementation2default:defaultZ17-83h px
}
Exiting %s at %s...
206*common2
Vivado2default:default2,
Thu Oct  8 18:07:06 20152default:defaultZ17-206h px