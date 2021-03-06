# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {Common-41} -limit 4294967295
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.cache/wt [current_project]
set_property parent.project_path C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/my_mult/fulladd.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/pack_xtras.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/my_sub.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/my_rege.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/my_pashiftreg_sclr.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/my_pashiftreg.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/my_counter.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/my_mult/my_mult.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/my_busmux3to1/my_busmux3to1.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/my_addsub/my_addsub.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/custom/custom_pkg.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/imports/rest_integer_iter_v1/res_div_iter.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/new/Grayscale.vhd
  C:/Users/mr_co_000/Documents/GitHub/ECE495/FinalProject/GrayScale/GrayScale.srcs/sources_1/new/Grayscale_Top.vhd
}
synth_design -top Grayscale_Top -part xc7z010clg400-1
write_checkpoint -noxdef Grayscale_Top.dcp
catch { report_utilization -file Grayscale_Top_utilization_synth.rpt -pb Grayscale_Top_utilization_synth.pb }
