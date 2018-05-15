#!/bin/sh -e

sudo python ./pins.py  #Sets the PI into operational mode
sudo python ./resetboard.py
sudo python ./resetdebug.py

./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt # Reload the program

while grep -q ERROR logoutput.txt
do
    sudo python ./pins.py
    sudo python ./resetboard.py
    sudo python ./resetdebug.py
    ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
done

for i in $(seq -w $3 200)
do
echo "\n ******* Trial Number : $i *******\n"

if  [ `expr $i % 10` -eq 0 ]; then
    python scan_chain.py $2${i}_1 #Scan Chain Read before zap
    sudo python ./pins.py
    echo "********\nReloading the program for the 10th trial********"	
    sudo python ./resetboard.py
    sudo python ./resetdebug.py

    ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt

    while grep -q ERROR logoutput.txt
    do
	echo "\n\n Core communication could not be established. Reloading the program \n"
        sudo python ./pins.py
        sudo python ./resetboard.py
        sudo python ./resetdebug.py
        ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
    done
fi

./openmsp430-start.tcl

sleep 2

./openmsp430-stop.tcl

dt=$(date '+%y%m%d%H%M%S')

echo "\n ************Reading data before zap *******************"

# Reading the sesors before zap

./openmsp430-readpc.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc1.txt $2${i}_${dt}pc1.txt
./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}reg1.txt $2${i}_${dt}reg1.txt
./openmsp430-readperiph.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}periph1.txt $2${i}_${dt}periph1.txt
./openmsp430-readmem.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}mem1.txt $2${i}_${dt}mem1.txt
python sensorread.py $2${i}_1 

./openmsp430-start.tcl
echo "Zapping"

./zap.exe

echo "\n**********************Reading the sensors after zap*********************************"

python sensorread.py $2${i}_2  # Reading the sensors after the zap

sleep 0.25
./openmsp430-stop.tcl | tee logoutput.txt


if grep -q "cpu_id not valid" logoutput.txt; then
     sudo python ./resetdebug.py
     echo "\n*********************************Restopping the program after the zap, as stopping didnt work****************" 
   
    ./openmsp430-stop.tcl | tee logoutput.txt  #It should restart the program 	
     #python pins.py
                
    if grep -q "cpu_id not valid" logoutput.txt; then #Worst case 
    	echo "\n\n **************Core communication could not be established. Reloading the program ********************* \n"
        sudo python ./pins.py
        sudo python ./resetboard.py
        sudo python ./resetdebug.py
        #./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt # Worst case reload
    fi
fi

echo "\n********************Reading after zap ******************"

./openmsp430-readpc.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc2.txt $2${i}_${dt}pc2.txt
./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}reg2.txt $2${i}_${dt}reg2.txt
./openmsp430-readperiph.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}periph2.txt $2${i}_${dt}periph2.txt
./openmsp430-readmem.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}mem2.txt $2${i}_${dt}mem2.txt

diff $2${i}_${dt}pc1.txt $2${i}_${dt}pc2.txt | tee $2${i}_${dt}diffpc.txt
diff $2${i}_${dt}reg1.txt $2${i}_${dt}reg2.txt | tee $2${i}_${dt}diffreg.txt
diff $2${i}_${dt}periph1.txt $2${i}_${dt}periph2.txt | tee $2${i}_${dt}diffperiph.txt
diff $2${i}_${dt}mem1.txt $2${i}_${dt}mem2.txt | tee $2${i}_${dt}diffmem.txt

if [ ! -s $2${i}_${dt}diffpc.txt ]
then
    rm -f $2${i}_${dt}diffpc.txt
fi

if [ ! -s $2${i}_${dt}diffreg.txt ]
then
    rm -f $2${i}_${dt}diffreg.txt
fi

if [ ! -s $2${i}_${dt}diffperiph.txt ]
then
    rm -f $2${i}_${dt}diffperiph.txt
fi

if [ ! -s $2${i}_${dt}diffmem.txt ]
then
    rm -f $2${i}_${dt}diffmem.txt
fi

done
