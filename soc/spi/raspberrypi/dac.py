import spidev
spi=spidev.SpiDev()
#open spi bus 0 and device 0
spi.open(0,0)
spi.max_speed_hz=976000

freq_out=400
#2^28=268435456
Two28=268435456
phase=0

def send_data(input):
    # tx_msb=input>>8
    # tx_lsb=input & 0xff
    # spi.xfer([tx_msb,tx_lsb])
    spi.xfer(input)
    # print(input)

# freq_word=int(round(float(freq_out*Two28)/25000000))
# MSB=(freq_word & 0xfffc000)>>14
# LSB=(freq_word & 0x3fff)
while True:
    send_data(0x3fff)
    # send_data(LSB)
    # send_data(MSB)
