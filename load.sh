#!/bin/sh
python pins.py
python resetboard.py
python resetdebug.py
./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1
sleep 2
./openmsp430-stop.tcl
./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2 $3
#./openmsp430-start.tcl
