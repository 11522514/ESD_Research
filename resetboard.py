import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False);
GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setup(19, GPIO.OUT)
GPIO.output(19,0)  # TO set the output bit to high
time.sleep(0.1)
GPIO.output(19,1)  # TO set the output bit to high
