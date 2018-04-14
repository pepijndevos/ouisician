import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

Fs = 48e3
amplitude = 4*16000
db = 20*np.log10(amplitude)

def timestamp(ps):
    return pd.Timestamp(int(ps)/1000., unit='ns')

def std_logic(bits):
    try:
        return int(bits, 2)
    except ValueError:
        return 0

def two_complement(value):
    length = len(value)
    value = std_logic(value)
    if (value & (1 << (length - 1))) != 0:
        value = value - (1 << length)
    return value

c = {0: timestamp,
     2: std_logic,
     3: two_complement}

data = pd.read_csv('list.lst',
        delim_whitespace=True,
        skiprows=2,
        index_col=0,
        header=None,
        names=['ps', 'delta', 'sndclk', 'resp'],
        converters=c)

resp = data[data['sndclk']==1][pd.Timestamp(0.5, unit='ms'):]['resp']

print(resp)

dft = np.fft.fft(resp)
frq = np.arange(len(dft))*Fs/len(dft)

plt.semilogx(frq,20*np.log10(abs(dft))-db)
plt.grid(True, which='both')
plt.xlabel("Frequency [hz]")
plt.ylabel("Amplitude [dB]")
plt.xlim(0, Fs/2)
plt.show()
