#Start###################################################################
puts “=================”
puts “Started”
puts “=================”

#set DESIGN <Your_module_name>
set DESIGN cam



#set the LIB’s path as a variable ‘LIB_DIR’
set LIB_DIR /opt/eda/cadence/local/GSCLIB045_Fall2024_SymbolwithVDDVSS/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_all_v4.4/gsclib045/timing
######################################################################
#set the search path for the “.lib’ files provided with the PDK.
set_attribute lib_search_path $LIB_DIR
#select the needed .lib files.
set_attribute library {slow_vdd1v2_basicCells.lib}
######################################################################

set RTL_DIR /home/shaikaz/Cam/Genus/synth/Input_files/RTL
##Verilog##
read_hdl $RTL_DIR/cam.v

elaborate $DESIGN

#return problems with your RTL code.
check_design -unresolved
#Read in your clock difinition and timing constraints
set SDC_DIR /home/shaikaz/Cam/Genus/synth/Input_files/SDC
read_sdc $SDC_DIR/Constraints.sdc

######################################################################
#Synthesizing to generic cell (not related to the used PDK)
syn_gen

#Synthesizing to gates from the used PDK
syn_map

#Incremental Synthesis
syn_opt -incr
#Insert Tie Hi and Tie low cells
#insert_tiehilo_cells

######################################################################
#write output files and generate reports
set OUTPUT_DIR /home/shaikaz/Cam/Genus/synth/Output_files
report area > $OUTPUT_DIR/${DESIGN}_area.rpt
report gates > $OUTPUT_DIR/${DESIGN}_gates.rpt
report timing -worst 200 > $OUTPUT_DIR/${DESIGN}_timing.rpt
report power > $OUTPUT_DIR/${DESIGN}_power.rpt
#Generate the verilog file with actual gates-> to be used in Innovus and Xcelium
##Verilog
write_hdl -mapped > $OUTPUT_DIR/${DESIGN}_map.v
#generate the constaraints file–> to be used in Innovus
write_sdc > $OUTPUT_DIR/${DESIGN}_map.sdc
#generate the delays file–> to be used in Xcelium
write_sdf > $OUTPUT_DIR/${DESIGN}_map.sdf

#THE END
puts “=====================”
puts “Finished”
puts “=====================”
