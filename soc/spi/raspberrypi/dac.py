import spidev
spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,0)
spi.max_speed_hz=976000

refFreq=50*10**6
#2^28=268435456
Two28=268435456
phase=0

def send_data(fre):
    freWord=fre*Two28/refFreq
    MSB=int((freWord & 0xfffc000) >> 14)
    LSB=int(freWord & 0x3fff)
    LSB|=0x4000
    MSB|=0x4000
    spi.xfer([LSB,MSB])

while True:
    send_data(1000)
