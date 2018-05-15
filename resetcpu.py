import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False);
GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setup(13, GPIO.OUT)
GPIO.output(13,0)  # TO set the output bit to high
time.sleep(1)
GPIO.output(13,1)  # TO set the output bit to high
