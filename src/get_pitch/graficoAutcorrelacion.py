
# Este código es el que hicimos para la P2. Tenemos que adaptarlo para que plotee un tramo sonoro con su periodo claro.
#Tambien tiene que plotear la autocorrelación de ese mismo tramo.
#Es posible que exista una mejor manera, pero se me ocurre sacar en 2 .txt tanto un tramo que sea sonoro como su autocorrelación
#A partir de los .txt plotearemos tanto uno como otro

import matplotlib.pyplot as plt
import soundfile as sf
import numpy as np

audio, fm = sf.read('../../30ms.wav')

t= np.arange(0, len(audio))/fm #Devuelve un vector de valores equispaciados entre 0 y la longitud del fichero. 
                                  #(Normalizamos a fm)

fig, axs = plt.subplots(2)
fig.suptitle('Audio original VS Audio con silencios')
axs[0].plot(t, audio)
#axs[1].plot()  plot de la autocorrelación

plt.show()  