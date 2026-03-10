# XiangShan ASAP7 Synthesis - Filename Setup
# Adapted from RSD synthesis flow

puts "RM-Info: Running script [info script]\n"

#################################################################################
# Design Compiler Reference Methodology Filenames Setup
#################################################################################

set INPUTS_DIR ${DESIGN_NAME}_xs/inputs/
set REPORTS_DIR ${DESIGN_NAME}_xs/${PERIOD}/reports/
set OUTPUTS_DIR ${DESIGN_NAME}_xs/${PERIOD}/outputs/
set RESULTS_DIR  ${DESIGN_NAME}_xs/${PERIOD}/netlist/

set SCENARIO mode_norm_ws0_wc_125

file mkdir ${INPUTS_DIR}
file mkdir ${REPORTS_DIR}
file mkdir ${OUTPUTS_DIR}
file mkdir ${RESULTS_DIR}


###############
# Input Files #
###############

set DCRM_SDC_INPUT_FILE                                 ${INPUTS_DIR}/${DESIGN_NAME}.sdc
set DCRM_CONSTRAINTS_INPUT_FILE                         ${INPUTS_DIR}/${DESIGN_NAME}.constraints.tcl

###########
# Reports #
###########

set DCRM_CHECK_LIBRARY_REPORT                           ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_check_library.rpt
set DCRM_CONSISTENCY_CHECK_ENV_FILE                     ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}.compile_ultra.env
set DCRM_CHECK_DESIGN_REPORT                            ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}.check_design.rpt
set DCRM_ANALYZE_DATAPATH_EXTRACTION_REPORT             ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}.analyze_datapath_extraction.rpt

set DCRM_FINAL_QOR_REPORT                               ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_qor.rpt
set DCRM_FINAL_TIMING_REPORT                            ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_timing.rpt
set DCRM_FINAL_AREA_REPORT                              ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_area.rpt
set DCRM_FINAL_POWER_REPORT                             ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_power.rpt
set DCRM_FINAL_CLOCK_GATING_REPORT                      ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_clock_gating.rpt
set DCRM_FINAL_SELF_GATING_REPORT                       ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_self_gating.rpt
set DCRM_THRESHOLD_VOLTAGE_GROUP_REPORT                 ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_threshold.voltage.group.rpt
set DCRM_INSTANTIATE_CLOCK_GATES_REPORT                 ${REPORTS_DIR}/${DESIGN_NAME}_${TECH}_synth_instatiate_clock_gates.rpt

################
# Output Files #
################

set DCRM_AUTOREAD_RTL_SCRIPT                            ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}.autoread_rtl.tcl
set DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE              ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}.elab.ddc
set DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE                  ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}.compile_ultra.ddc
set DCRM_FINAL_DDC_OUTPUT_FILE                          ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}_synth.ddc
set DCRM_FINAL_VERILOG_OUTPUT_FILE                      ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}_synth.v
set DCRM_FINAL_SDC_OUTPUT_FILE                          ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}_synth.${SCENARIO}.sdc
set DCRM_FINAL_SPEF_OUTPUT_FILE                         ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}_synth.${SCENARIO}.spef
set DCRM_FINAL_FSDB_OUTPUT_FILE                         ${OUTPUTS_DIR}/${DESIGN_NAME}_${TECH}_synth.fsdb
set DCRM_FINAL_VCD_OUTPUT_FILE                          ${OUTPUTS_DIR}/${DESIGN_NAME}_${TECH}_synth.vcd
set DCRM_FINAL_SDF_OUTPUT_FILE                          ${RESULTS_DIR}/${DESIGN_NAME}_${TECH}_synth.${SCENARIO}.sdf


puts "RM-Info: Completed script [info script]\n"
