# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/lab3/lab3.cache/wt [current_project]
set_property parent.project_path C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/lab3/lab3.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/lpm_pack.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/fulladd.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/my4to1LUT_atan.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/my_rege.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/my_addsub.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/mux_2to1.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/lpm_clshift.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/Lab/Lab3/CORDIC_FP_top.vhd
}
synth_design -top CORDIC_FP_top -part xc7z010clg400-1
write_checkpoint -noxdef CORDIC_FP_top.dcp
catch { report_utilization -file CORDIC_FP_top_utilization_synth.rpt -pb CORDIC_FP_top_utilization_synth.pb }
