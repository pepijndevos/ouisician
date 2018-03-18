import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

Fs = 48e3
amplitude = 0x3fff
db = 20*np.log10(amplitude)

def timestamp(ps):
    return pd.Timestamp(int(ps)/1000., unit='ns')

def std_logic(bits):
    try:
        return int(bits, 2)
    except ValueError:
        return 0

c = {0: timestamp,
     3: std_logic}

data = pd.read_csv('list.lst',
        delim_whitespace=True,
        skiprows=2,
        index_col=0,
        header=None,
        names=['ps', 'delta', 'sndclk', 'resp'],
        converters=c)

resp = data[data['sndclk']==0]['resp']

dft = np.fft.fft(resp)
frq = np.arange(len(dft))*Fs/len(dft)

plt.plot(frq,20*np.log10(abs(dft))-db)
plt.xlabel("Frequency [hz]")
plt.ylabel("Amplitude [dB]")
plt.xlim(0, Fs/2)
plt.show()
