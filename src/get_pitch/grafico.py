
# Este código es el que hicimos para la P2. Tenemos que adaptarlo para que plotee un tramo sonoro con su periodo claro.
#Tambien tiene que plotear la autocorrelación de ese mismo tramo.
#Es posible que exista una mejor manera, pero se me ocurre sacar en 2 .txt tanto un tramo que sea sonoro como su autocorrelación
#A partir de los .txt plotearemos tanto uno como otro

import matplotlib.pyplot as plt
import soundfile as sf
import numpy as np

audio_orig, fm_o = sf.read('pav_2151.wav')
audio_silen, fm_s = sf.read('pav_2151_s.wav')

t_o = np.arange(0, len(audio_orig))/fm_o #Devuelve un vector de valores equispaciados entre 0 y la longitud del fichero. 
t_s = np.arange(0, len(audio_silen))/fm_s #(Normalizamos a fm)

fig, axs = plt.subplots(2)
fig.suptitle('Audio original VS Audio con silencios')
axs[0].plot(t_o, audio_orig)
axs[1].plot(t_s, audio_silen)

plt.show()  