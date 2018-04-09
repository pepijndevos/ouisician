import spidev
spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,0)
spi.max_speed_hz=976000

freq_out=400
#2^28=268435456
Two28=268435456
phase=0


while True:
    spi.writebytes(0x0002)
