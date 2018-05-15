#!/bin/sh -e
sudo python ./pins.py  #Sets the PI into operational mode
sudo python ./resetboard.py
sudo python ./resetdebug.py
./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
while grep -q ERROR logoutput.txt
do
    sudo python ./resetboard.py
    sudo python ./resetdebug.py
    ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
done

for i in $(seq -w $3 200)
do
    echo "\n Trial Number $i \n"
    if  [ `expr $i % 10` -eq 0 ]
    then
        echo "Reloading the Program \n"
        python scan_chain.py $2${i}
        sudo python ./resetboard.py
        sudo python ./resetdebug.py
        ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
        while grep -q ERROR logoutput.txt
        do
            sudo python ./pins.py
            sudo python ./resetboard.py
            sudo python ./resetdebug.py
            ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
        done
    fi

    ./openmsp430-start.tcl
    sleep 1

    dt=$(date '+%y%m%d%H%M%S')

    echo "\n ***** Data Read before Zaping ****** \n"
    ./openmsp430-stop.tcl
    if [ `expr $i % 10` -eq 0 ]
    then
        ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}_reload_r1.txt $2${i}_${dt}_reload_r1.txt
    else
        ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r1.txt $2${i}_${dt}r1.txt
    fi
    ./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc1.txt $2${i}_${dt}pc1.txt #read pc before zap

    python sensorread.py $2${i}_1 # This is with scan mode =0 ; there is no need to read sensors before the zap ; is this done only for Rui's monitors


    ./openmsp430-start.tcl

     echo "\n ****** Sleeping, so that the program runs for a while before zap **** \n	"
     sleep 0.5 # Prajwal thinks this matters     
	
    echo "\n ****** Zapping ******* \n"

    ./zap.exe
    sleep 1

    sudo python ./resetdebug.py
    ./openmsp430-stop.tcl | tee logoutput.txt
    if grep -q "cpu_id not valid" logoutput.txt; then
        echo "Resetting the board \n "

        python scan_chain.py $2${i}  #Scan_Mode = 1 and Scan_EN =1
	python sensorread.py $2${i}_2   # placing it after the scanchain so as to work reliably

        sudo python ./pins.py
        sudo python ./resetboard.py
        sudo python ./resetdebug.py
        ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
        while grep -q ERROR logoutput.txt
        do
            sudo python ./pins.py
            sudo python ./resetboard.py
            sudo python ./resetdebug.py
            ./openmsp430-loader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 $1 | tee logoutput.txt
        done
        continue  #Once you reset the board , you have lost all your data and there is no point to carry on. 
    fi

    if [ `expr $i % 10` -eq 0 ]
    then
        ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}_reload_r2.txt $2${i}_${dt}_reload_r2.txt
    else
        ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r2.txt $2${i}_${dt}r2.txt
    fi

    ./openmsp430-readreg.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}pc2.txt $2${i}_${dt}pc2.txt

    python sensorread.py $2${i}_2   # Im not sure this will work, but this should work 

    echo "Checking for flips \n"	
    if [ `expr $i % 10` -eq 0 ]
    then 
	diff $2${i}_${dt}_reload_r1.txt $2${i}_${dt}_reload_r2.txt | tee $2${i}_${dt}diff.txt  
    else
   	diff $2${i}_${dt}r1.txt $2${i}_${dt}r2.txt | tee $2${i}_${dt}diff.txt  
    fi	
	
    if [ ! -s $2${i}_${dt}diff.txt ]
    then
        rm -f $2${i}_${dt}diff.txt
    else
        ./openmsp430-start.tcl
        sleep 1
        ./openmsp430-stop.tcl
        ./openmsp430-reader.tcl -device /dev/ttyS0 -adaptor uart_generic -speed 2000000 -test $2${i}_${dt}r3.txt $2${i}_${dt}r3.txt
    fi
done
