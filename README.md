PAV - P3: detección de pitch
============================

Esta práctica se distribuye a través del repositorio GitHub [Práctica 3](https://github.com/albino-pav/P3).
Siga las instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para realizar un `fork` de la
misma y distribuir copias locales (*clones*) del mismo a los distintos integrantes del grupo de prácticas.

Recuerde realizar el *pull request* al repositorio original una vez completada la práctica.

Ejercicios básicos
------------------

- Complete el código de los ficheros necesarios para realizar la detección de pitch usando el programa
  `get_pitch`.

   * Complete el cálculo de la autocorrelación e inserte a continuación el código correspondiente.

> El código es el siguiente:
> 
```c
void PitchAnalyzer::autocorrelation(const vector<float> &x, vector<float> &r) const
  {

    for (unsigned int l = 0; l < r.size(); ++l)
    {
      /// \TODO Compute the autocorrelation r[l]

      r[l] = 0;
      for (unsigned int n = l; n < x.size(); n++)
      {
        r[l] += x[n] * x[n - l];
      }
// Valores de la autocorrelación de la trama salen en consola
#if 0
        cout << r[l] << endl;
#endif
    }

    if (r[0] == 0.0F) //to avoid log() and divide zero
      r[0] = 1e-10;

    /// \DONE Aplicamos la fórmula matemática de la autocorrelación
  }
``` 

   * Inserte una gŕafica donde, en un *subplot*, se vea con claridad la señal temporal de un segmento de
     unos 30 ms de un fonema sonoro y su periodo de pitch; y, en otro *subplot*, se vea con claridad la
	 autocorrelación de la señal y la posición del primer máximo secundario.

	 NOTA: es más que probable que tenga que usar Python, Octave/MATLAB u otro programa semejante para
	 hacerlo. Se valorará la utilización de la librería matplotlib de Python.

![grafAutocorrelacion](https://user-images.githubusercontent.com/65824775/116000269-ca9d3800-a5ef-11eb-8e67-0e2404de3dbd.png)


   * Determine el mejor candidato para el periodo de pitch localizando el primer máximo secundario de la
     autocorrelación. Inserte a continuación el código correspondiente.
     
```c
for (iR = r.begin() + npitch_min; iR < r.begin() + npitch_max; iR++)
    {
      if (*iR > *iRMax)
      {
        iRMax = iR;
      }
    }
```

   * Implemente la regla de decisión sonoro o sordo e inserte el código correspondiente.
> La potencia nos servirá para descartar una gran parte de las tramas sordas que detectamos como sonoras, estas serían las llamadas VU. (de esta forma no estimamos su pitch) En el caso de las UV (tramas sonoras detectadas como sordas), creemos que es más conveniente tratar de diferenciarlas mediante las autocorrelaciones.
```c
if (trama == 0)
    {
      potencia_inicial = pot;
      trama = 1;
      return true;
    }
    if (pot > potencia_inicial + p_th || (r1norm > r1_th && rmaxnorm > rlag_th))
    {                                                                     
      return false; //Decidimos que es trama de VOZ / SONORA
    }
    else
    {
      return true; //Decidimos que es trama de SILENCIO / SORDA
    }
      /// \DONE A partir de los valores de potencia y autocorrelación, creamos un decisor de tramas sonoras/sordas
  }
```

- Una vez completados los puntos anteriores, dispondrá de una primera versión del detector de pitch. El 
  resto del trabajo consiste, básicamente, en obtener las mejores prestaciones posibles con él.

  * Utilice el programa `wavesurfer` para analizar las condiciones apropiadas para determinar si un
    segmento es sonoro o sordo. 
	
	  - Inserte una gráfica con la detección de pitch incorporada a `wavesurfer` y, junto a ella, los 
	    principales candidatos para determinar la sonoridad de la voz: el nivel de potencia de la señal
		(r[0]), la autocorrelación normalizada de uno (r1norm = r[1] / r[0]) y el valor de la
		autocorrelación en su máximo secundario (rmaxnorm = r[lag] / r[0]).

		Puede considerar, también, la conveniencia de usar la tasa de cruces por cero.

	    Recuerde configurar los paneles de datos para que el desplazamiento de ventana sea el adecuado, que
		en esta práctica es de 15 ms.
> Miramos la potencia, y vemos más o menos la diferencia de potencia entre los segmentos de silencio y los sonoros. La primera trama de audio tiene 10 db’s de potencia, pero justo antes de hablar, nos situamos en los 24 db’s. Con 35 db’s ya se ha empezado a hablar realmente, con una potencia que luego va incrementando hasta casi 54 db’s. El silencio entre las dos primeras palabras se sitúa por debajo de los 35 db’s.

> Para obtener los valores de la autocorrelación, que se calculan ya para cada trama, hacemos uso de la librería de entrada/salida de C++, y usamos la función cout que nos permite sacar por consola la información para cada trama (en este caso la potencia, la autocorrelación en 1 y en el desplazamiento equivalente al pitch normalizadas).

```c
#if 0
    if (r[0] > 0.0F)
      cout << pot << '\t' << r[1]/r[0] << '\t' << r[lag]/r[0] << endl;
#endif

    if (unvoiced(pot, r[1] / r[0], r[lag] / r[0]))
      return 0;
    else
      return (float)samplingFreq / (float)lag; //retornamos el pitch en hercios
```
> Luego desde la consola, hacemos que en vez de que la salida se escriba en consola, se escriba en un fichero .out. Posteriormente, para ver la representación del r(1)/r(0) y r(lag)/r(0), recortamos las columnas respectivas con el comando ‘cut’ y lo ponemos en otros dos ficheros separados, que luego introduciremos en wavesurfer.

<imagen graf>

> Como podríamos esperar , las autocorrelaciones normalizadas de 1 y en el pitch, tienen un valor cercano a 1 ahi donde tenemos tramas sonoras. Esto es así ya que las muestras cercanas de las tramas de voz tienen una alta correlación entre ellas (de ahí que r(1)/r(0) tenga un valor alto. En el caso concreto de este audio >0.75 podríamos decir que se trata de una trama de voz), y el valor de r(lag)/r(0) tambien se espera que sea un valor cercano a 1, ya que la señal se parece con ella misma si la desplazamos de n_pitch muestras (o lag) (en este caso en particular podríamos decir que para valores superiores a 0.5 (o 0.4).
> En base a estos resultado, hemos decidido ser más restrictivos con la autocorrelación en 1 normalizada, y más laxos en la del pitch. Obtenemos los siguientes resultados.

      - Use el detector de pitch implementado en el programa `wavesurfer` en una señal de prueba y compare
	    su resultado con el obtenido por la mejor versión de su propio sistema.  Inserte una gráfica
		ilustrativa del resultado de ambos detectores.
  
  * Optimice los parámetros de su sistema de detección de pitch e inserte una tabla con las tasas de error
    y el *score* TOTAL proporcionados por `pitch_evaluate` en la evaluación de la base de datos 
	`pitch_db/train`..

   * Inserte una gráfica en la que se vea con claridad el resultado de su detector de pitch junto al del
     detector de Wavesurfer. Aunque puede usarse Wavesurfer para obtener la representación, se valorará
	 el uso de alternativas de mayor calidad (particularmente Python).
   

Ejercicios de ampliación
------------------------

- Usando la librería `docopt_cpp`, modifique el fichero `get_pitch.cpp` para incorporar los parámetros del
  detector a los argumentos de la línea de comandos.
  
  Esta técnica le resultará especialmente útil para optimizar los parámetros del detector. Recuerde que
  una parte importante de la evaluación recaerá en el resultado obtenido en la detección de pitch en la
  base de datos.

  * Inserte un *pantallazo* en el que se vea el mensaje de ayuda del programa y un ejemplo de utilización
    con los argumentos añadidos.

- Implemente las técnicas que considere oportunas para optimizar las prestaciones del sistema de detección
  de pitch.

  Entre las posibles mejoras, puede escoger una o más de las siguientes:

  * Técnicas de preprocesado: filtrado paso bajo, *center clipping*, etc.
  * Técnicas de postprocesado: filtro de mediana, *dynamic time warping*, etc.
  * Métodos alternativos a la autocorrelación: procesado cepstral, *average magnitude difference function*
    (AMDF), etc.
  * Optimización **demostrable** de los parámetros que gobiernan el detector, en concreto, de los que
    gobiernan la decisión sonoro/sordo.
  * Cualquier otra técnica que se le pueda ocurrir o encuentre en la literatura.

  Encontrará más información acerca de estas técnicas en las [Transparencias del Curso](https://atenea.upc.edu/pluginfile.php/2908770/mod_resource/content/3/2b_PS%20Techniques.pdf)
  y en [Spoken Language Processing](https://discovery.upc.edu/iii/encore/record/C__Rb1233593?lang=cat).
  También encontrará más información en los anexos del enunciado de esta práctica.

  Incluya, a continuación, una explicación de las técnicas incorporadas al detector. Se valorará la
  inclusión de gráficas, tablas, código o cualquier otra cosa que ayude a comprender el trabajo realizado.

  También se valorará la realización de un estudio de los parámetros involucrados. Por ejemplo, si se opta
  por implementar el filtro de mediana, se valorará el análisis de los resultados obtenidos en función de
  la longitud del filtro.
   

Evaluación *ciega* del detector
-------------------------------

Antes de realizar el *pull request* debe asegurarse de que su repositorio contiene los ficheros necesarios
para compilar los programas correctamente ejecutando `make release`.

Con los ejecutables construidos de esta manera, los profesores de la asignatura procederán a evaluar el
detector con la parte de test de la base de datos (desconocida para los alumnos). Una parte importante de
la nota de la práctica recaerá en el resultado de esta evaluación.
