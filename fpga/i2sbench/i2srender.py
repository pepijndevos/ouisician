import pandas 
import matplotlib.pyplot as plt
data = pandas.read_csv('i2secho.csv')

chan = pandas.DataFrame({
    "ch1":data.Value[0::4].values,
    "ch2":data.Value[1::4].values,
    "ch3":data.Value[2::4].values,
    "ch4":data.Value[3::4].values})

chan.plot()
plt.show()
