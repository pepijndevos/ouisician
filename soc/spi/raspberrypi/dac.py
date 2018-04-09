import spidev
import RPi.GPIO as GPIO

spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,0)


def writeFrequency(freq):
    freWord=int (freq*2**28/refFreq)
    MSB=int((freWord & 0xfffc000) >> 14)
    LSB=int(freWord & 0x3fff)
    LSB|=0x4000
    MSB|=0x4000
    spi.xfer([LSB,MSB,0x2000])

while True:
    send_data(1000)
