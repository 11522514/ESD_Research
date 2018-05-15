#!/bin/sh -e
for i in $(seq -w $3 200)
do
sudo python ./pins.py  # this sets the scan enable = 0 and the scan mode =0 
sudo python ./resetboard.py
sudo python ./resetdebug.py

./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt  #Reloading the program at the beginning. 

echo "\n ******* Trial Number : $i *******\n"

while grep -q ERROR logoutput.txt
do
    sudo python ./pins.py
    sudo python ./resetboard.py
    sudo python ./resetdebug.py
    ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
done

sleep 2
./openmsp430-stop.tcl

dt=$(date '+%y%m%d%H%M%S')

./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r1.txt $2${i}_${dt}r1.txt
./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc1.txt $2${i}_${dt}pc1.txt

python sensorread.py $2${i}_1 # Reading the sesors before zaps

./openmsp430-start.tcl

echo " \n ****** Zapping ****** \n"

./zap.exe

sleep 1

./openmsp430-stop.tcl | tee logoutput.txt  #Reseting the debug interface 
if grep -q "cpu_id not valid" logoutput.txt; then
    python sensorread.py $2${i}_2
    python scan_chain.py $2${i}
    sudo python pins.py
    sudo python ./resetboard.py
    sudo python ./resetdebug.py
    continue
fi
./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r2.txt $2${i}_${dt}r2.txt
./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc2.txt $2${i}_${dt}pc2.txt

diff $2${i}_${dt}r1.txt $2${i}_${dt}r2.txt | tee $2${i}_${dt}diff.txt

if [ ! -s $2${i}_${dt}diff.txt ]
then
    rm -f $2${i}_${dt}diff.txt
    echo "No Reset"
else
    ./openmsp430-start.tcl
    sleep 1
    ./openmsp430-stop.tcl
    ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r3.txt $2${i}_${dt}r3.txt
fi

python sensorread.py $2${i}_2	 #ScanMode  = 1 & ScanEn = 1 for the sensor read program to work reliabaly
python scan_chain.py $2${i}      #Scan Chain read for this program; Scan_mode =1 & Scan_en = 1

done
