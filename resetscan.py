import RPi.GPIO as GPIO
import time
import os

GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setwarnings(False)

GPIO.setup(5, GPIO.OUT)
GPIO.output(5,1) #scan_en = 0
time.sleep(0.01)
GPIO.output(5,0)

