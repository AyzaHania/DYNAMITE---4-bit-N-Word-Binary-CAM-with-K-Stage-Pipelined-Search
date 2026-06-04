current_design recognizer

create_clock -name "clk" -period 1.190 -waveform {0.0 0.136} [get_ports clk]

#set_input_delay -clock [get_clocks clk] -add_delay 0.5 [get_ports x]
set_input_delay -clock [get_clocks clk] -add_delay 0.0 [get_ports x]
set_input_delay -clock [get_clocks clk] -add_delay 0.0 [get_ports reset]
set_output_delay -clock [get_clocks clk] -add_delay 0.0 [get_ports y]

set_dont_use [get_lib_cells *] true
set_attribute avoid false INVX1 NAND2X1 NOR2X1 OR2X1 AND2X1 XOR2X1 XNOR2X1 DFFRHQX1




# set_wire_load_mode  "top"
# set_wire_load_model "TSMC_13k_Conservative" -library "ss_1v08_125c.lib"
# set_wire_load_model -name "TSMC32K_Lowk_Conservative" -library "tcbn65lp_c050428wc"
#set_max_capacitance 15.000 [current_design]
#set_max_transition 0.28 [current_design]
#set_max_fanout 15.00 [current_design]
#set_operating_conditions –name “PVT_1P08V_125C” – library “slow_vdd1v2”
#set_false_path -from [get_ports reset]
#set_attribute preserve false TIEHI TIELO
#set_attribute avoid false TIEHI TIELO
#set_attribute preserve false INVX1 NAND2X1 NOR2X1 OR2X1 AND2X1 XOR2X1 XNOR2X1 DFFRHQX1
