import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom

GPIO.setup(13, GPIO.OUT)
GPIO.output(13,1)  # TO set the output bit to high
GPIO.setup(19, GPIO.OUT)
GPIO.output(19,1)  # TO set the output bit to high
GPIO.setup(6,GPIO.OUT)

GPIO.output(6,0)
GPIO.setup(5,GPIO.OUT)

GPIO.output(5,0)
GPIO.setup(26,GPIO.OUT)
GPIO.setup(25,GPIO.OUT)
GPIO.setup(24,GPIO.OUT)
GPIO.output(26, 0)  #C
GPIO.output(25, 1)  #A
GPIO.output(24, 1)  #B
GPIO.setup(16, GPIO.OUT)  #COM
GPIO.output(16,0)       #set scanmode to 1
#GPIO.cleanup()
