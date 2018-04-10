import spidev
import time
spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,1)
spi.max_speed_hz=10**3
spi.mode=0b10

def setFrequency(freqRef,freq):
    if freq>freqRef:
        freq=freqRef
    elif freq<0:
        freq=0

    freqWord=int ((freq*2**28)/freqRef)
    LSB= int (freqWord & 0x3fff)
    MSB= int ((freqWord & 0xfffc000)>>14)
    #freq0_write_reg
    LSB|=0x4000
    MSB|=0x4000
    spi.xfer([LSB,MSB])

def setPhase(phaseRef,phase):
    phase %=360
    phaseVal = (int(4096*phase/360)) & 0x0fff
    #phase 0
    phaseVal |= 0xc000
    spi.xfer2([phaseVal])


freqRef = 10**5
phaseRef = 360
try:
    #spi.xfer([0x0002])
    while(True):
        spi.writebytes([0x0002])
        #spi.xfer([0x2])
        #spi.xfer2([0x2002])
        setFrequency(freqRef,2000)
        #setPhase(phaseRef,0)

except (KeyboardInterrupt,Exception) as e:
    print(e)
    print('closing spi')
    spi.close()



