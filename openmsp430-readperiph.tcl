#!/usr/bin/tclsh
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
#
# File Name: openmsp430-loader.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 210 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2015-11-17 10:57:08 +0100 (Tue, 17 Nov 2015) $
#------------------------------------------------------------------------------

global omsp_conf
global omsp_info

# Detect toolchain
if {[catch {exec msp430-gcc --version} debug_info]} {
    if {[catch {exec msp430-elf-gcc --version} debug_info]} {
	puts "\nERROR: Could not detect MSP430 GCC toolchain"
	exit 1
    } else {
	set TOOLCHAIN_PFX "msp430-elf"
    }
} else {
    set TOOLCHAIN_PFX "msp430"
}

###############################################################################
#                            SOURCE LIBRARIES                                 #
###############################################################################

# Get library path
set current_file [info script]
if {[file type $current_file]=="link"} {
    set current_file [file readlink $current_file]
}
set lib_path [file dirname $current_file]/../lib/tcl-lib

# Source library
source $lib_path/dbg_functions.tcl
source $lib_path/dbg_utils.tcl


###############################################################################
#                            PARAMETER CHECK                                  #
###############################################################################
#proc GetAllowedSpeeds

proc help {} {
    puts ""
    puts "USAGE   : openmsp430-reader.tcl \[-device   <communication port>\]"
    puts "                                \[-adaptor  <adaptor type>\]"
    puts "                                \[-speed    <communication speed>\]"
    puts "                                \[-test     <test file>\]               <outputfile>"
    puts ""
    puts "DEFAULT : <communication port>  = /dev/ttyUSB0"
    puts "          <adaptor type>        = uart_generic"
    puts "          <communication speed> = 115200 (for UART)"
    puts "          <core address>        = 42"
    puts ""
    puts "EXAMPLES: openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test test.txt out.txt"
    puts ""
}

# Default values
set omsp_conf(interface)  uart_generic
set omsp_conf(device)     /dev/ttyS0
set omsp_conf(baudrate)   [lindex [GetAllowedSpeeds] 1]
set omsp_conf(0,cpuaddr)  42
set out_file              -1
set test_file             -1
set bin_file              "[clock clicks].bin"

# Parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
        -device   {set omsp_conf(device)    [lindex $argv [expr $i+1]]; incr i}
        -adaptor  {set omsp_conf(interface) [lindex $argv [expr $i+1]]; incr i}
        -speed    {set omsp_conf(baudrate)  [lindex $argv [expr $i+1]]; incr i}
        -test     {set test_file            [lindex $argv [expr $i+1]]; incr i}
        default   {set out_file             [lindex $argv $i]}
    }
}

# Make sure arugments were specified
if {[string eq $out_file -1]} {
    puts "\nERROR: output file isn't specified"
    help
    exit 1
}

# Make sure arugments were specified
if {[string eq $test_file -1]} {
    puts "\nERROR: test file isn't specified"
    help
    exit 1
}


# Make sure the selected adptor is valid
if {![string eq $omsp_conf(interface) "uart_generic"]} {
    puts "\nERROR: Specified adaptor is not valid (should be \"uart_generic\")"
    help
    exit 1
}

# If the selected interface is a UART, make sure the selected speed is an integer
if {[string eq $omsp_conf(interface) "uart_generic"]} {
    if {![string is integer $omsp_conf(baudrate)]} {
        puts "\nERROR: Specified UART communication speed is not an integer"
        help
        exit 1
    }
}

###############################################################################
#                      LOAD PROGRAM TO OPENMSP430 TARGET                      #
###############################################################################

# Connect to target and stop CPU
#puts            ""
#puts -nonewline "Connecting with the openMSP430 ($omsp_conf(device), $omsp_conf(baudrate)\ bps)... "
flush stdout
if {![GetDevice 0]} {
    puts "failed"
    puts "Could not open $omsp_conf(device)"
    puts "Available serial ports are:"
    foreach port [utils::uart_port_list] {
    puts "                             -  $port"
    }
    exit 1
}

set sizes [GetCPU_ID_SIZE 0]

if {$omsp_info(0,alias)!=""} {
    puts "Connected: target device identified as $omsp_info(0,alias)."
}
#puts "Connected: target device has [lindex $sizes 0]B Program Memory and [lindex $sizes 1]B Data Memory"
#puts ""

# Load Program Memory
# Open the output file
set out [open $out_file w]
#puts $out ""
#puts "Outputting SFR"
#puts $out "SFR:"
puts $out [ReadMemQuick 0 0x0000 0x0001]
puts $out [ReadMemQuick 0 0x0002 0x0001]
puts $out [ReadMemQuick 0 0x0004 0x0001]
puts $out [ReadMemQuick 0 0x0006 0x0001]
puts $out [ReadMemQuick 0 0x0008 0x0001]
#after 2
#puts $out ""
#puts "Outputting GPIOs"
#puts $out "GPIOs:"
#puts $out [ReadMemQuick8 0 0x0020 0x0007]
puts $out [ReadMemQuick 0 0x0020 0x0001]
puts $out [ReadMemQuick 0 0x0022 0x0001]
puts $out [ReadMemQuick 0 0x0024 0x0001]
puts $out [ReadMemQuick8 0 0x0026 0x0001]00
#after 2
puts $out [ReadMemQuick 0 0x0028 0x0001]
puts $out [ReadMemQuick 0 0x002A 0x0001]
puts $out [ReadMemQuick 0 0x002C 0x0001]
puts $out [ReadMemQuick8 0 0x002E 0x0001]00
#after 2
puts $out [ReadMemQuick 0 0x0018 0x0001]
puts $out [ReadMemQuick 0 0x001A 0x0001]
#after 2
puts $out [ReadMemQuick 0 0x001C 0x0001]
puts $out [ReadMemQuick 0 0x001E 0x0001]
#after 2
puts $out [ReadMemQuick 0 0x0030 0x0001]
puts $out [ReadMemQuick 0 0x0032 0x0001]
#after 2
puts $out [ReadMemQuick 0 0x0034 0x0001]
puts $out [ReadMemQuick 0 0x0036 0x0001]
#after 2
#puts $out ""
#puts "Outputting Clock Module"
#puts $out "Clock:"
puts $out [ReadMemQuick8 0 0x0057 0x0001]00
puts $out [ReadMemQuick8 0 0x0058 0x0001]00
#after 2
#puts $out ""
#puts "Outputting Watchdog Timer"
#puts $out "Watchdog:"
puts $out [ReadMemQuick 0 0x0120 0x0001]
#after 2
#puts $out ""
#puts "Outputting Multiplier"
#puts $out "Multiplier:"
puts $out [ReadMemQuick 0 0x0130 0x0001]
puts $out [ReadMemQuick 0 0x0132 0x0001]
puts $out [ReadMemQuick 0 0x0134 0x0001]
puts $out [ReadMemQuick 0 0x0136 0x0001]
puts $out [ReadMemQuick 0 0x0138 0x0001]
puts $out [ReadMemQuick 0 0x013A 0x0001]
puts $out [ReadMemQuick 0 0x013C 0x0001]
puts $out [ReadMemQuick 0 0x013E 0x0001]
#after 2
#puts $out ""
#puts "Outputting Timer"
#puts $out "Timer"
puts $out [ReadMemQuick 0 0x0160 0x0001]
puts $out [ReadMemQuick 0 0x0162 0x0001]
puts $out [ReadMemQuick 0 0x0164 0x0001]
puts $out [ReadMemQuick 0 0x0166 0x0001]
#after 2
puts $out [ReadMemQuick 0 0x0170 0x0001]
puts $out [ReadMemQuick 0 0x0172 0x0001]
puts $out [ReadMemQuick 0 0x0174 0x0001]
puts $out [ReadMemQuick 0 0x0176 0x0001]
#after 2
puts $out [ReadMemQuick 0 0x012E 0x0001]

close $out
utils::uart_close
#after 10
