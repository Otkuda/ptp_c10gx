
# (C) 2001-2025 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Intel 
# Program License Subscription Agreement, Intel MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Intel and sold by Intel 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     myPLL
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Intel simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "mentor.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
# #
# # Source the generated IP simulation script.
# source $QSYS_SIMDIR/mentor/msim_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
# dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
# com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog <compilation options> <design and testbench files>
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
# elab
# #
# # Run the simulation.
# run -a
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If myPLL is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Intel IP
# within the Quartus project, and generate a unified
# script which supports all the Intel IP within the design.
# ----------------------------------------
# ACDS 24.3 212 win32 2025.05.19.10:16:27

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "myPLL.myPLL"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "C:/intelfpga_pro/24.3/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_VHDL_COMPILE_OPTIONS] { 
  set USER_DEFINED_VHDL_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_VERILOG_COMPILE_OPTIONS] { 
  set USER_DEFINED_VERILOG_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

if ![info exists SILENCE] { 
  set SILENCE "false"
}

if ![info exists PRECOMP_DEVICE_LIB_FILE] { 
  set PRECOMP_DEVICE_LIB_FILE ""
}

if ![info exists FORCE_MODELSIM_AE_SELECTION] { 
  set FORCE_MODELSIM_AE_SELECTION "false"
}

#-------------------------------------------
# read .tcl file to override initialized variables  
if { [info exists ::env(QSYS_SIM_SCRIPT_QUESTASIM_OPTIONS_FILE)] && [file exist $::env(QSYS_SIM_SCRIPT_QUESTASIM_OPTIONS_FILE)] } {
  echo "Sourcing $::env(QSYS_SIM_SCRIPT_QUESTASIM_OPTIONS_FILE)" 
  source $::env(QSYS_SIM_SCRIPT_QUESTASIM_OPTIONS_FILE)
}


# ----------------------------------------
# Source Common Tcl File
source $QSYS_SIMDIR/common/modelsim_files.tcl


# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
set LD_LIBRARY_PATH [dict create]
if { ![ string match "*-64 vsim*" [ vsimVersionString ] ] } {
  set SIMULATOR_TOOL_BITNESS "bit_32"
} else {
  set SIMULATOR_TOOL_BITNESS "bit_64"
}
set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [myPLL::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
if {[dict size $LD_LIBRARY_PATH] !=0 } {
  set LD_LIBRARY_PATH [subst [join [dict keys $LD_LIBRARY_PATH] ":"]]
  setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH"
}
append ELAB_OPTIONS [subst [myPLL::get_elab_options $SIMULATOR_TOOL_BITNESS]]
append SIM_OPTIONS [subst [myPLL::get_sim_options $SIMULATOR_TOOL_BITNESS]]

proc check_precomp_device {precomp_device_lib_path force_select_modelsim_ae} {
  set len [string length $precomp_device_lib_path]
  if {($len == 0) && [string is false -strict [modelsim_ae_select $force_select_modelsim_ae]]} {
    return 1
  }
  return 0

}

proc modelsim_ae_select {force_select_modelsim_ae} {
  if [string is true -strict $force_select_modelsim_ae] {
    return 1
  }
  return [string match -nocase "*Intel*FPGA*" [ vsimVersionString ]]

}


# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] file_copy"
  }
  set memory_files [list]
  set memory_files [concat $memory_files [myPLL::get_memory_files "$QSYS_SIMDIR"]]
  foreach file $memory_files {
  set itercount 0
  while {$itercount < 10  && [file type $file] eq "link"} {
    set nf [file readlink $file]
    if {[string index $nf 0] ne "/"} {
    set nf [file dirname $file]/$nf
    }
    set file $nf
  }
  set dest_file [file join ./ [file tail $file]]
  set normalized_src [myPLL::normalize_path "$file"]
  set normalized_dest [myPLL::normalize_path "$dest_file"]
  if { $normalized_src ne $normalized_dest } {
    file copy -force $file ./
  }
  }
  
}
# ----------------------------------------
# Modify modelsim.ini if precompiled device libraries are in use
if { $PRECOMP_DEVICE_LIB_FILE ne "" } {
  echo "Modifying modelsim.ini according to $PRECOMP_DEVICE_LIB_FILE"
  set PRECOMP_DEVICE_LIB_FILE [string trim $PRECOMP_DEVICE_LIB_FILE]
  if { [file exists $PRECOMP_DEVICE_LIB_FILE] && [string match [file tail $PRECOMP_DEVICE_LIB_FILE] "modelsim.ini" ] } {
    if { [file exists "modelsim.ini"] } {
      echo "modelsim.ini already exists, making backup modelsim.ini.bak"
      file copy -force "modelsim.ini" "modelsim.ini.bak"
    }
    echo "Copying modelsim.ini from $PRECOMP_DEVICE_LIB_FILE"
    file copy -force $PRECOMP_DEVICE_LIB_FILE ./
  } elseif { [file exists $PRECOMP_DEVICE_LIB_FILE] && [string match "*tcl" [file tail $PRECOMP_DEVICE_LIB_FILE] ] } {
    echo "Running $PRECOMP_DEVICE_LIB_FILE to generate device library mapping"
    source $PRECOMP_DEVICE_LIB_FILE
  } else {
    echo "Unable to use $PRECOMP_DEVICE_LIB_FILE for device library mapping. Switching back to local library compilation"
    set PRECOMP_DEVICE_LIB_FILE ""
  }
}

# ----------------------------------------
# Create compilation libraries

set logical_libraries [list "work" "work_lib" "lpm_ver" "sgate_ver" "altera_ver" "altera_mf_ver" "altera_lnsim_ver" "cyclone10gx_ver" "cyclone10gx_hip_ver" "cyclone10gx_hssi_ver"]

proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib          ./libraries/     
ensure_lib          ./libraries/work/
vmap       work     ./libraries/work/
vmap       work_lib ./libraries/work/

# ----------------------------------------
# get DPI libraries
set libraries [dict create]
set libraries [dict merge $libraries [myPLL::get_dpi_libraries "$QSYS_SIMDIR"]]
set dpi_libraries [dict values $libraries]

# ----------------------------------------
# setup shared libraries
set DPI_LIBRARIES_ELAB ""
if { [llength $dpi_libraries] != 0 } {
  echo "Using DPI Library settings"
  foreach library $dpi_libraries {
    append DPI_LIBRARIES_ELAB "-sv_lib $library "
  }
}

if [ check_precomp_device $PRECOMP_DEVICE_LIB_FILE $FORCE_MODELSIM_AE_SELECTION ] {
  ensure_lib                      ./libraries/lpm_ver/             
  vmap       lpm_ver              ./libraries/lpm_ver/             
  ensure_lib                      ./libraries/sgate_ver/           
  vmap       sgate_ver            ./libraries/sgate_ver/           
  ensure_lib                      ./libraries/altera_ver/          
  vmap       altera_ver           ./libraries/altera_ver/          
  ensure_lib                      ./libraries/altera_mf_ver/       
  vmap       altera_mf_ver        ./libraries/altera_mf_ver/       
  ensure_lib                      ./libraries/altera_lnsim_ver/    
  vmap       altera_lnsim_ver     ./libraries/altera_lnsim_ver/    
  ensure_lib                      ./libraries/cyclone10gx_ver/     
  vmap       cyclone10gx_ver      ./libraries/cyclone10gx_ver/     
  ensure_lib                      ./libraries/cyclone10gx_hip_ver/ 
  vmap       cyclone10gx_hip_ver  ./libraries/cyclone10gx_hip_ver/ 
  ensure_lib                      ./libraries/cyclone10gx_hssi_ver/
  vmap       cyclone10gx_hssi_ver ./libraries/cyclone10gx_hssi_ver/
}
set design_libraries [dict create]
set design_libraries [dict merge $design_libraries [myPLL::get_design_libraries]]
set libraries [dict keys $design_libraries]
foreach library $libraries {
  ensure_lib ./libraries/$library/
  vmap $library  ./libraries/$library/
  lappend logical_libraries $library
}

# ----------------------------------------
# Compile device library files
alias dev_com {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] dev_com"
  }
  if [ check_precomp_device $PRECOMP_DEVICE_LIB_FILE $FORCE_MODELSIM_AE_SELECTION ] {
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                             -work lpm_ver             
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                -work sgate_ver           
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                    -work altera_ver          
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                            -work altera_mf_ver       
    eval  vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                        -work altera_lnsim_ver    
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclone10gx_atoms.v"                    -work cyclone10gx_ver     
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/cyclone10gx_atoms_ncrypt.v"      -work cyclone10gx_ver     
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/cyclone10gx_hip_atoms_ncrypt.v"  -work cyclone10gx_hip_ver 
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclone10gx_hip_atoms.v"                -work cyclone10gx_hip_ver 
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/cyclone10gx_hssi_atoms_ncrypt.v" -work cyclone10gx_hssi_ver
    eval  vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclone10gx_hssi_atoms.v"               -work cyclone10gx_hssi_ver
  }
  
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] com"
  }
  set design_files [dict create]
  set design_files [dict merge [myPLL::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
  set common_design_files [dict values $design_files]
  foreach file $common_design_files {
    eval $file
  }
  set design_files [list]
  set design_files [concat $design_files [myPLL::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
  foreach file $design_files {
    eval $file
  }
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] elab"
  }
  set elabcommand " $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS"
  foreach library $logical_libraries { append elabcommand " -L $library" }
  append elabcommand " $TOP_LEVEL_NAME $DPI_LIBRARIES_ELAB "
  eval vsim $elabcommand
}

# ----------------------------------------
# Elaborate the top level design with -voptargs=+acc option
alias elab_debug {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] elab_debug"
  }
  set elabcommand " $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS"
  foreach library $logical_libraries { append elabcommand " -L $library" }
  append elabcommand " $TOP_LEVEL_NAME $DPI_LIBRARIES_ELAB "
  eval vsim -voptargs=+acc $elabcommand
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with  -voptargs=+acc
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                                         -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                                           -- Compile device library files"
  echo
  echo "com                                               -- Compile the design files in correct order"
  echo
  echo "elab                                              -- Elaborate top level design"
  echo
  echo "elab_debug                                        -- Elaborate the top level design with -voptargs=+acc option"
  echo
  echo "ld                                                -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                                          -- Compile all the design files and elaborate the top level design with  -voptargs=+acc"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                                    -- Top level module name."
  echo "                                                     For most designs, this should be overridden"
  echo "                                                     to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME                              -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                                       -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR                               -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS                      -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VHDL_COMPILE_OPTIONS                 -- User-defined vhdl compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VERILOG_COMPILE_OPTIONS              -- User-defined verilog compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS                         -- User-defined elaboration options, added to elab/elab_debug aliases."
  echo
  echo "SILENCE                                           -- Set to true to suppress all informational and/or warning messages in the generated simulation script. "
  echo
  echo "PRECOMP_DEVICE_LIB_FILE                           -- Precompiled device library file."
  echo "                                                    Use this variable to provide modelsim.ini or tcl containing device library mapping and dev_com will be skipped"
  echo "                                                    If value is empty, device libraries will be compiled local"
  echo
  echo "FORCE_MODELSIM_AE_SELECTION                       -- Set to true to force to select Modelsim AE always."
}
file_copy
h
