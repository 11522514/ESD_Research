import RPi.GPIO as GPIO
import time
import os

GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setwarnings(False)
GPIO.setup(13, GPIO.OUT)
GPIO.output(13,1)  # TO set the output bit to high
os.system("gpio mode 16 ALT5")
GPIO.setup(6,GPIO.OUT)   #DCO_Relay
GPIO.output(6,0)

GPIO.setup(5, GPIO.OUT)
GPIO.output(5,0) #scan_en = 0

GPIO.setup(26, GPIO.OUT)
GPIO.setup(12, GPIO.OUT)
GPIO.setup(25, GPIO.OUT)
GPIO.output(26,0)  #C 
GPIO.output(12,1)  #B
GPIO.output(25,1)  #A
GPIO.setup(16,GPIO.OUT)  #SCAN_Mode = 0
GPIO.output(16,0)
