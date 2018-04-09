import spidev
import RPi.GPIO as GPIO

spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,0)
# spi.mode=0b10
refFreq = 50*10**6

# def writeFrequency(freq):
#     freWord=int (freq*2**28/refFreq)
#
#     MSB=int((freWord & 0xfffc000) >> 14)
#     LSB=int(freWord & 0x3fff)
#     LSB|=0x4000
#     MSB|=0x4000
#     spi.writebytes([LSB,MSB])

while True:
    # send_data(1000)
    spi.xfer([0b0010000101101000])
