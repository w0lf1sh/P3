import matplotlib.pyplot as plt
import soundfile as sf
import numpy as np

#Read audio file
audio, fm = sf.read('../../30ms.wav')

#Time axis
time = (np.linspace(0, len(audio)-1, len(audio)))/fm 
                                                 
#Compute autocorrelation and axis
r = np.correlate(audio, audio, "same")
r = r / r[int(len(r)/2)] 
raxis = np.arange(len(r))

#Plotting the graphs
plt.subplot(2,1,1)
plt.plot(time, audio, lineWidth=0.75)
plt.grid(True)
plt.xlabel("Time(s)")
plt.ylabel("amplitude")

plt.subplot(2,1,2)
plt.plot(raxis, r, lineWidth=0.75)
plt.grid(True)
plt.xlabel("Samples")
plt.ylabel("autocorrelation")

plt.show()  