# XiangShan ASAP7 Synthesis Script
# Adapted from RSD synthesis flow for XiangShan Nanhu processor

source -echo -verbose scripts/dc_setup.tcl

set clk_name main_clk
set clk_port io_clock
set clk_ports_list [list $clk_port]
set clk_period $PERIOD
set input_delay $INPUT_DELAY
set output_delay $OUTPUT_DELAY

sh rm -rf work
sh mkdir work
define_design_lib xs_lib -path work

# --- SRAM macro support ---
if {[info exists ::env(USE_SRAM_MACROS)] && $::env(USE_SRAM_MACROS) == 1} {
    puts "RM-Info: SRAM macro mode enabled"
    set sram_db_dir $::env(SRAM_DB_DIR)
    set sram_db_files $::env(SRAM_DB_FILES)

    # Add SRAM .db files to link_library and search_path
    set_app_var search_path "$sram_db_dir $search_path"
    foreach db $sram_db_files {
        set_app_var link_library "* $db $link_library"
    }
    puts "RM-Info: link_library = $link_library"
}

# Source the generated file list (all synthesizable RTL from build/rtl/)
source Flist.xs_synth

# If SRAM macro mode, analyze wrapper (overrides array_* modules) and macro Verilog
if {[info exists ::env(USE_SRAM_MACROS)] && $::env(USE_SRAM_MACROS) == 1} {
    puts "RM-Info: Analyzing SRAM macro Verilog models..."
    foreach vf [glob -nocomplain ./fakeram7_*.v] {
        analyze -f sverilog -lib xs_lib $vf
    }
    puts "RM-Info: Analyzing SRAM wrapper (overrides array_* modules)..."
    analyze -f sverilog -lib xs_lib ./xs_sram_wrapper.sv
}

elaborate ${DESIGN_NAME} -library xs_lib

uniquify
link

# If SRAM macro mode, protect macro instances from optimization
if {[info exists ::env(USE_SRAM_MACROS)] && $::env(USE_SRAM_MACROS) == 1} {
    puts "RM-Info: Setting dont_touch on SRAM macro instances..."
    foreach macro {fakeram7_8192x64 fakeram7_1024x160 fakeram7_1024x56 fakeram7_1024x7
                   fakeram7_512x308 fakeram7_256x24 fakeram7_256x16 fakeram7_128x230
                   fakeram7_128x100 fakeram7_128x50 fakeram7_128x40 fakeram7_64x192
                   fakeram7_64x64 fakeram7_32x1024 fakeram7_32x108 fakeram7_4x1044
                   fakeram7_4x2672 fakeram7_2048x4 fakeram7_256x24_0 fakeram7_8x236
                   fakeram7_8x512} {
        catch {set_dont_touch [get_cells -hier -filter "ref_name == $macro"]}
    }
}

# Create clock constraint on io_clock
create_clock [get_ports $clk_port] -name $clk_name -period $clk_period

write -hierarchy -format ddc -output ${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

# Set false path for debug/diagnostic ports (not timing-critical)
catch {set_false_path -to [get_ports io_debug*]}
catch {set_false_path -to [get_ports io_uart*]}

change_name -rule verilog -hier

# Prevent assignment statements in the Verilog netlist
set_fix_multiple_port_nets -all -buffer_constants

# Check the current design for consistency
check_design -summary > ${DCRM_CHECK_DESIGN_REPORT}

# Disable leakage power optimization (saves significant runtime)
set_leakage_optimization false

compile_ultra -no_boundary_optimization

change_names -rules verilog -hierarchy

write -format verilog -hierarchy -output ${DCRM_FINAL_VERILOG_OUTPUT_FILE}
write -format verilog -hierarchy -output ${DESIGN_NAME}_synth.v
write -format ddc     -hierarchy -output ${DCRM_FINAL_DDC_OUTPUT_FILE}

# Capture reports into variables first, then write to files and summary
redirect -variable timing_rpt {report_timing -nworst 10 -nosplit}
redirect -variable area_rpt {report_area -nosplit}
redirect -variable area_hier_rpt {report_area -hier -nosplit}
redirect -variable power_rpt {report_power -nosplit}

# Write report files
set timing_fh [open ${DCRM_FINAL_TIMING_REPORT} w]
puts $timing_fh $timing_rpt
close $timing_fh

set area_fh [open ${DCRM_FINAL_AREA_REPORT} w]
puts $area_fh $area_hier_rpt
close $area_fh

set power_fh [open ${DCRM_FINAL_POWER_REPORT} w]
puts $power_fh $power_rpt
close $power_fh

write_sdc ${DCRM_FINAL_SDC_OUTPUT_FILE}

# Generate synthesis summary report
set summary_file ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_summary.rpt
set fh [open $summary_file w]
puts $fh "========================================================================"
puts $fh "  XiangShan Processor Synthesis Summary"
puts $fh "  Design: ${DESIGN_NAME}  Tech: ${TECH}"
puts $fh "  Clock Period: ${clk_period} (time units from library)"
puts $fh "  Date: [date]"
puts $fh "========================================================================"
puts $fh ""

# Timing summary
puts $fh "--- TIMING ---"
if {[regexp {slack \((\w+)\)\s+([-\d.]+)} $timing_rpt match status slack_val]} {
    puts $fh "  Worst slack: $slack_val ($status)"
} else {
    puts $fh "  Worst slack: (could not parse)"
}
if {[regexp {data arrival time\s+([\d.]+)} $timing_rpt match arrival]} {
    puts $fh "  Critical path delay: $arrival"
}
puts $fh ""

# Area summary
puts $fh "--- AREA ---"
if {[regexp {Total cell area:\s+([\d.]+)} $area_rpt match total_area]} {
    puts $fh "  Total cell area: $total_area"
}
if {[regexp {Combinational area:\s+([\d.]+)} $area_rpt match comb_area]} {
    puts $fh "  Combinational: $comb_area"
}
if {[regexp {Noncombinational area:\s+([\d.]+)} $area_rpt match seq_area]} {
    puts $fh "  Sequential: $seq_area"
}
if {[regexp {Macro/Black Box area:\s+([\d.]+)} $area_rpt match macro_area]} {
    puts $fh "  Macro/Black Box: $macro_area"
}
if {[regexp {Number of cells:\s+(\d+)} $area_rpt match num_cells]} {
    puts $fh "  Number of cells: $num_cells"
}
if {[regexp {Number of sequential cells:\s+(\d+)} $area_rpt match num_seq]} {
    puts $fh "  Number of sequential cells: $num_seq"
}
puts $fh ""

# Power summary
puts $fh "--- POWER ---"
if {[regexp {Total Dynamic Power\s+=\s+([\d.e+-]+)\s+(\w+)} $power_rpt match dyn_pwr dyn_unit]} {
    puts $fh "  Total Dynamic Power: $dyn_pwr $dyn_unit"
}
if {[regexp {Cell Leakage Power\s+=\s+([\d.e+-]+)\s+(\w+)} $power_rpt match leak_pwr leak_unit]} {
    puts $fh "  Cell Leakage Power: $leak_pwr $leak_unit"
}
puts $fh ""

# Top-level area breakdown
puts $fh "--- TOP-LEVEL AREA BREAKDOWN ---"
foreach line [split $area_hier_rpt "\n"] {
    if {[regexp {^(\S+)\s+([\d.]+)\s+([\d.]+)\s+} $line match cell abs_area pct]} {
        set depth [llength [split $cell "/"]]
        if {$depth == 1 && $cell ne "XSTop" && $cell ne "Total" && [string is double $abs_area] && $abs_area > 0} {
            puts $fh [format "  %-45s %10s  %5s%%" $cell $abs_area $pct]
        }
    }
}
puts $fh ""

puts $fh "========================================================================"
close $fh

puts "RM-Info: Summary report written to $summary_file"

exit
