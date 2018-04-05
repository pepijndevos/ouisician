import spidev
#import time
spi=spidev.SpiDev()
#open spi bus device 
spi.open(0,0)
#maximum clock frequency
#can only be 125000000, 62500000,31200000,15600000,7800000,3900000,1953000,976000,488000,244000,122000,61000,30500,15200,7629
spi.max_speed_hz=244000

while True:
    spi.xfer([0xff,0xff])

