import RPi.GPIO as GPIO
import time

GPIO.setwarnings(False);
GPIO.setmode(GPIO.BCM)  # set board mode to Broadcom
GPIO.setup(27, GPIO.IN)
GPIO.setup(22, GPIO.OUT)
GPIO.output(22,0)
i = 0
while(1):
   i = (i + 1) % 100000
   GPIO.output(22,GPIO.input(27))
   #if i == 500:
       #print(GPIO.input(27))
