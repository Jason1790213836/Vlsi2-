define_design_lib WORK -path ./work

set LIB_PATH "./DCNXT_2021.06/ref/DBs"
set_app_var search_path "$LIB_PATH . $search_path"
set_app_var target_library "saed32lvt_ss0p75v125c.db"
set_app_var link_library "* $target_library"

analyze -format sverilog {decoder.sv counter.sv controller.sv comparator.sv multiplexer.sv sram.sv bist.sv}
elaborate bist

current_design bist
link

read_sdc constraint.sdc

compile

report_timing > reports/timing.rpt
report_area > reports/area.rpt
report_power > reports/power.rpt

write -hierarchy -format verilog -output mapped/bist_netlist.v

exit
