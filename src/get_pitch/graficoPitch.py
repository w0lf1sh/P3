import matplotlib.pyplot as plt
import numpy as np


#Read files
computedPitch = np.loadtxt('pitch_db/train/rl001.f0')
wavesurferPitch = np.loadtxt('rl001_wavesurfer.f0')


#Time axis
time = np.zeros(len(computedPitch))
for i in range(len(computedPitch)):
    time[i] = i * 0.015


#Plotting the graph
plt.plot(time, computedPitch,'c', label = 'Computed Pitch')
plt.plot(time, wavesurferPitch,'m', label = 'Wavesurfer Pitch')

plt.xlabel('Time(s)')
plt.ylabel('Frequency(Hz)')
plt.title('Pitch comparison')
plt.legend(loc = 'upper right')
plt.show()  