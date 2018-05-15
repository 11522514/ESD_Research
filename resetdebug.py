import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False);

GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setup(26,GPIO.OUT)
GPIO.setup(25,GPIO.OUT)
GPIO.setup(12,GPIO.OUT)
GPIO.setup(16, GPIO.OUT)  #COM
GPIO.output(26, 1)  #C
GPIO.output(12, 1)  #B
GPIO.output(25, 1)  #A
GPIO.output(16,0)       #set dbg_en to 0
time.sleep(1)
GPIO.output(16,1)       #set dbg_en to 1
