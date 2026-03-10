# XiangShan ASAP7 Synthesis - DC Setup
# Adapted from RSD synthesis flow

# Variables common to all reference methodology scripts
set PERIOD                        [getenv PERIOD];
set DESIGN_NAME                   [getenv DESIGN_NAME]  ;#  The name of the top-level design
set TECH                          [getenv TECH_NAME];
set techno                        [getenv TECH_NAME];
set FOUNDRY_PATH                  [getenv FOUNDRY_PATH];
set TARGET_LIBRARY_FILES          [getenv TARGET_LIBRARY_FILES];
set INPUT_DELAY                   [getenv INPUT_DELAY];
set OUTPUT_DELAY                  [getenv OUTPUT_DELAY];

set ADDITIONAL_LINK_LIB_FILES     "                                  ";

# Remove messages
suppress_message LINK-17
suppress_message MWLIBP-300
suppress_message MWLIBP-301
suppress_message MWLIBP-319
suppress_message MWLIBP-324
suppress_message MWLIBP-311
suppress_message MWLIBP-032
suppress_message UCN-1
suppress_message UID-282

set ADDITIONAL_SEARCH_PATH " ${FOUNDRY_PATH}/synopsys ${FOUNDRY_PATH} ";
set_app_var search_path ". ${ADDITIONAL_SEARCH_PATH} $search_path"

if {$synopsys_program_name == "dc_shell"}  {
  set_app_var target_library ${TARGET_LIBRARY_FILES}
  set_app_var synthetic_library dw_foundation.sldb
  set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"
}

source -echo -verbose scripts/dc_setup_filenames.tcl

# The following setting removes new variable info messages from the end of the log file
set_app_var sh_new_variable_message false

if {$synopsys_program_name == "dc_shell"}  {

  #################################################################################
  # Design Compiler Setup Variables
  #################################################################################

  set_host_options -max_cores 16

  # Persistent alib cache (not deleted by 'make clean', reused across runs)
  catch {sh mkdir -p ../alib_cache}
  catch {sh mkdir -p ./alib_cache}
  if {[file isdirectory ../alib_cache]} {
    set_app_var alib_library_analysis_path ../alib_cache
  } else {
    set_app_var alib_library_analysis_path ./alib_cache
  }

  # Naming rules for Verilog output
  define_name_rules verilog \
    -target_bus_naming_style "%s\[%d\]" \
    -allowed "a-z0-9_" \
    -first_restricted "0-9_" \
    -replacement_char "_" \
    -equal_ports_nets -inout_ports_equal_nets \
    -collapse_name_space -case_insensitive -special verilog \
    -add_dummy_nets \
    -dummy_net_prefix "synp_unconn_%d"

  # Eliminate tri-state nets and assign primitives in the output netlist
  set_app_var verilogout_no_tri true

  # Preserve FF with no load used as spare
  set_app_var hdlin_preserve_sequential ff+loop_variables

  ### Module name naming style
  set_app_var template_parameter_style "%s"
  set_app_var template_naming_style "%s"

}
