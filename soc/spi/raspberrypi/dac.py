# import spidev
# spi=spidev.SpiDev()
# #open spi bus 0 and device 0
# spi.open(0,0)
# spi.max_speed_hz=976000
#
# freq_out=400
# #2^28=268435456
# Two28=268435456
# phase=0
#
# def send_data(input):
#     # tx_msb=input>>8
#     # tx_lsb=input & 0xff
#     # spi.xfer([tx_msb,tx_lsb])
#     spi.xfer([0xfff,0xfff0])
#     # print(input)
#
# # freq_word=int(round(float(freq_out*Two28)/25000000))
# # MSB=(freq_word & 0xfffc000)>>14
# # LSB=(freq_word & 0x3fff)
# while True:
#     send_data(0x3fff)
#     # send_data(LSB)
#     # send_data(MSB)

import spidev
import time
#preparing SPI
spi=spidev.SpiDev()
spi.open(0,1)
spi.max_speed_hz=976000
#Intialization
freq_out=400
Two28 = 268435456 #this value equal to the 2^28
phase =0

#this method is responsible for sending data through SPI bus
def send_data(input):
tx_msb=input>>8
tx_lsb=input & 0xFF
spi.xfer([tx_msb,tx_lsb])
print(input)

#calculation for the frequency
freq_word=int(round(float(freq_out*Two28)/25000000))

#frequency word divide to two parts as MSB and LSB.
# FFFC ->1111 1111 1111 1100 0000 0000
MSB = (freq_word & 0xFFFC000)>>14
# 3FFF ->0011 1111 1111 1111
LSB = (freq_word & 0x3FFF)

#DB15 and DB14 are set to 0 and 1
LSB |= 0x4000
#DB15 and DB14 are set to 0 and 1
MSB |= 0x4000
#DB15, DB14,DB13 = 110 DB12 =x
#respectively, which is the address for Phase Register 0.
#The remaining 12 bits are the data bits and are all 0s in this case
phase |= 0xC000
#0x2100 - Control Register
send_data(0x2100)
#sending LSB and MSB
send_data(LSB)
send_data(MSB)
#sending phase
send_data(phase)
#0x2000 - Exit Reset
send_data(0x2000)
