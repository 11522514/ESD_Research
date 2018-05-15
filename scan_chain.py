import RPi.GPIO as GPIO
import time
import random
import sys
import datetime
random.seed(3)
GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setwarnings(False)
filename=sys.argv[1]
dt=datetime.datetime.now().strftime("%y%m%d%H%M%S")
filename=filename+'_'+dt+'scan.txt'
fl = open(filename,"w")
print(filename)
test_scan_out_pin = 15
GPIO.setup(test_scan_out_pin, GPIO.IN)  #Test Scan
GPIO.setup(23, GPIO.OUT)
GPIO.setup(4, GPIO.OUT) #Scan Clk
GPIO.setup(5, GPIO.OUT) #Scan En

GPIO.setup(12, GPIO.OUT)  # B
GPIO.setup(25, GPIO.OUT)  # A
GPIO.setup(26, GPIO.OUT)  # C

# Setting CBA = 011 for scan Mode 
GPIO.output(26, 0)  #C
GPIO.output(25, 1)  #A
GPIO.output(12, 1)  #B
GPIO.setup(16, GPIO.OUT)  #COM
GPIO.output(16,1)	#set scanmode to 1
GPIO.setup(6, GPIO.OUT) #Scan Clk enable
GPIO.output(6, 1)
time.sleep(.01)

testsi = 0
scanmode = 1 
scanenable = 0
GPIO.output(5, scanenable)
scanclock = 0
GPIO.output(4, 0)
time.sleep(.001)

data=[]
print("Reset off")
dt =1/15e3 
scanenable = 1 
GPIO.output(5, scanenable)
stra = ''
time.sleep(.005)
for i in range(1):
    for j in range(3700):
	stra = stra + str(GPIO.input(test_scan_out_pin))
	if j>=2000 and GPIO.input(test_scan_out_pin)==1:
	    print(j-2001)
	fl.write(str(j)+','+str(testsi)+','+str(GPIO.input(test_scan_out_pin))+'\n')
        testsi = int(j==2000)
        GPIO.output(23, testsi)
        GPIO.output(4, 1)
        time.sleep(dt)
        GPIO.output(4, 0)
        time.sleep(dt)
GPIO.output(16,0)
GPIO.output(5,0)
GPIO.output(6,0)
print('SCAN function executed')
fl.close()
