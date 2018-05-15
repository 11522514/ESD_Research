import RPi.GPIO as GPIO
import time
import sys
import datetime

GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setwarnings(False)
GPIO.setup(3, GPIO.OUT)   #I2C_SLC
GPIO.setup(17, GPIO.OUT)  #I2C_Dir 
GPIO.output(17,1)
GPIO.setup(12, GPIO.OUT)  # B
GPIO.setup(25, GPIO.OUT)  # A
GPIO.setup(26, GPIO.OUT)  # C

# Address bits to be input MSB First
GPIO.setup(27,GPIO.OUT)
GPIO.setup(22,GPIO.OUT)
GPIO.output(27,1);
GPIO.output(22,1);
address_bits = [[0,0,0,0,0,0,0,0],[1,0,0,1,0,0,0,0], [0,1,0,0,1,0,0,0] , [1,1,0,1,1,0,0,0] , [0,0,1,0,0,1,0,0], [1,0,1,1,0,1,0,0], [1,1,0,0,1,1,0,0], [1,1,1,1,1,1,0,0], [1,1,0,0,0,0,0,1,0], [1,1,0,1,0,0,1,0],[1,1,1,0,1,0,1,0]]
monitor_name = [ "FLIPPER_0", "HVOV_0", "HVUV_0", "LVOV_0", "LVUV_0", "FLIPPER_1", "HVOV_1", "HVUV_1", "LVOV_1", "LVUV_1", "ORED"] 
dt=datetime.datetime.now().strftime("%y%m%d%H%M%S")
filename=sys.argv[1]
filename=filename+'_'+dt+'sensor.txt'
#filename1='SWM_'+filename
f1=open(filename,"w")
#f2=open(filename1,"w")
for x in range(2):
    for j in range(11):
        
        for i in range(7,-1,-1):

    # For shifting in the address
            GPIO.output(26,0) # C=0
            GPIO.output(12,1) # B=1
            GPIO.output(25,0) # A=0
            GPIO.setup(16,GPIO.OUT)
            GPIO.output(16,address_bits[j][i])
            time.sleep(0.0001) #charges the capacitor
    # For shifting in the clock
            GPIO.output(26,1) # C=1
            GPIO.output(16,1)
            time.sleep(0.00005)
            GPIO.output(16,0)
            time.sleep(0.00005)

        GPIO.setup(16, GPIO.IN)
	GPIO.output(26,0) # C=0
	GPIO.output(12,0) # B=0
	GPIO.output(25,0) # A=0
	time.sleep(0.0001)
	data2 = GPIO.input(16)
        if j == 1:
            print("PC Going: %d" %(data2))
        if j == 2:
            print("Done All: %d" %(data2))
        if j == 3:
            print("Pmem_Bad: %d" %(data2))
        if j == 4:
            print("Dmem_Bad: %d" %(data2))
        if j == 5:
            print("Time_out: %d" %(data2))
        if j == 6:
            print("I2C_ERROR: %d" %(data2))
        if j < 7 and j > 0:
            f1.write(str(data2)+'\n')
	GPIO.output(26,0) # C=0
	GPIO.output(12,0) # B=0
	GPIO.output(25,1) # A=0
	time.sleep(0.0001)
	for k in range(0,2):
            GPIO.output(3,k)
            data1 = GPIO.input(16)
            if( k==0 and (0<j<5 or 5<j<10)):
                datahigh=GPIO.input(16)
            elif( k==1 and (0<j<5 or 5<j<10)):
                datalow=GPIO.input(16)
            elif (k == 1 and monitor_name[j] is "ORED"):
		print("I2C_oredh: %d" %data1)
		if(x==0): f1.write('0'+str(data1)+'\n')
            elif (k == 0 and monitor_name[j] is "ORED"):
		print("GPIO_4_oredl: %d" %data1)
		if(x==0): f1.write('0'+str(data1)+'\n')
        if(0<j<5 or 5<j<10):
	    print("%s:%d%d " %(monitor_name[j],datahigh,datalow))
	    if(x==0): f1.write(str(datahigh)+str(datalow)+'\n')
        if ((monitor_name[j] is "FLIPPER_0")):
	    print("FLIPPER_0: %d" %data1)
	    if(x==0): f1.write('0'+str(data1)+'\n')
        elif ((monitor_name[j] is "FLIPPER_1")):
	    print("FLIPPER_1: %d" %data1)
	    if(x==0): f1.write('0'+str(data1)+'\n')
    if x==0:
	 print("\n\n------------------reset-------------------")
         GPIO.output(26,1) # C=1
         GPIO.output(12,0) # B=0
         GPIO.output(25,0) # A=0
         GPIO.setup(16,GPIO.OUT)
         GPIO.output(16,1)
         time.sleep(.01)
         GPIO.output(16,0)
         time.sleep(.01)
         GPIO.output(26,0)
      
f1.close
time.sleep(1)
