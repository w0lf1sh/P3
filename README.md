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

> Haciendo zoom en la primera zona, donde se ve el primer máximo secundario claramente:

![grafAutocorrelacionZoom](https://user-images.githubusercontent.com/65824775/116000357-27005780-a5f0-11eb-992c-f5b3a75a5c8f.png)


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
> Tras ver las gráficas de wavesurfer, nos damos cuenta que la manera en que decidimos si una trama es voz o no se queda obsoleta. Sobre todo porque basamos la potencia en la primera trama del primer audio debido a que usamos variables estáticas. Por lo que ahora, queriendo prescindir de estas, y dándonos cuenta de que: 
> 1) Como comentamos más arriba, las autocorrelaciones y las potencias no coinciden como nos gustaría para decidir si una trama es sorda, por lo que optamos por solo usar ORs y plantear las inecuaciones al revés, que es donde suelen existir las dudas
> 2) La potencia es alta donde  la persona habla, pero también para algunos tramas donde hay ruido
> 3) Como vemos para las autocorrelaciones (sobretodo en 1) esta es alta para tramos sonoros incluido tramos que no son realmente de voz (cuando el locutor ha acabado de hablar, vemos que la autocorrelación sigue siendo elevada)
> Nos queda por lo tanto asi:
```c
if (pot < p_th || r1norm < r1_th || rmaxnorm < rlag_th) 
    {                                                                     
      return true; //Decidimos que es trama de SILENCIO / SORDA
    }
    else
    {
      return false; //Decidimos que es trama de VOZ / SONORA
    }
      /// \DONE A partir de los valores de potencia y autocorrelación, creamos un decisor de tramas sonoras/sordas
  }
```
> Puntuación final habiendo implementado: Center clipping, Filtro de mediana y Ventana de Hamming.

> Si ejecutamos el script de optimización de parámetros con esta nueva manera de decidir si una trama es de voz o no, nos sale los siguientes resultados:
> Potencia: -20 dBs
> Autocorrelación en 1: 0.9
> Autocorrelación en desplazamiento pitch:  0.4

> Dándonos un score de 89,71%

<img src="https://user-images.githubusercontent.com/65824775/116004859-f8d94280-a604-11eb-92d6-215563bd3f4a.png" width="500">


   * Inserte una gráfica en la que se vea con claridad el resultado de su detector de pitch junto al del
     detector de Wavesurfer. Aunque puede usarse Wavesurfer para obtener la representación, se valorará
	 el uso de alternativas de mayor calidad (particularmente Python).
	 
> Gráfica con el filtro de mediana ya implementado (se incluye una explicación en el apartado de Ejercicios de ampliación):

<img src="https://user-images.githubusercontent.com/65824775/116001175-7f852400-a5f3-11eb-95a4-122ebcbdf9ac.png" width="500">

Ejercicios de ampliación
------------------------

- Usando la librería `docopt_cpp`, modifique el fichero `get_pitch.cpp` para incorporar los parámetros del
  detector a los argumentos de la línea de comandos.
  
  Esta técnica le resultará especialmente útil para optimizar los parámetros del detector. Recuerde que
  una parte importante de la evaluación recaerá en el resultado obtenido en la detección de pitch en la
  base de datos.

  * Inserte un *pantallazo* en el que se vea el mensaje de ayuda del programa y un ejemplo de utilización
    con los argumentos añadidos.
> Queremos pasar a través de la consola los umbrales para nuestros distintos parámetros que determinan si una señal es sonora o no. Para ello usaremos la librería docopt (language for description of command-line interfaces). 
> Primero modificamos el USAGE en get_pitch
```c
static const char USAGE[] = R"(
get_pitch - Pitch Detector 
Usage:
    get_pitch [options] <input-wav> <output-txt> 
    get_pitch (-h | --help)
    get_pitch --version
Options:
    -p FLOAT, --p_th=FLOAT         Margen en dBs para la potencia [default: -20.0]
    -r FLOAT, --r1_th=FLOAT        Margen de la autocorrelación normalizada en 1 [default: 0.9]
    -m FLOAT, --rlag_th=FLOAT      Margen de la autocorrelación normalizada en posición de pitch [default: 0.4]
    -x FLOAT, --x_th=FLOAT         Margen de center-clipping [default: 0.00007]
    -h, --help                     Show this screen
    --version                      Show the version of the project
Arguments:
    input-wav   Wave file with the audio signal
    output-txt  Output file: ASCII file with the result of the detection:
                    - One line per frame with the estimated f0
                    - If considered unvoiced, f0 must be set to f0 = 0
)";
```
> Posteriormente en el main, rescatamos los valores especificados en consola:
```c
int main(int argc, const char *argv[]) {
	/// \TODO 
	///  Modify the program syntax and the call to **docopt()** in order to
	///  add options and arguments to the program.
    std::map<std::string, docopt::value> args = docopt::docopt(USAGE,
        {argv + 1, argv + argc},	// array of arguments, without the program name
        true,    // show help if requested
        "2.0");  // version string

  std::string input_wav = args["<input-wav>"].asString();
  std::string output_txt = args["<output-txt>"].asString();

  float p = std::stof(args["--p_th"].asString());
  float r1 = std::stof(args["--r1_th"].asString());
  float rlag = std::stof(args["--rlag_th"].asString());
  float x_th = std::stof(args["--x_th"].asString());
  /// \DONE Paso de parámetros por consola implementado
```
> (usamos la función stof() para pasar de string a float)
> Por último modificamos el constructor  del Pitch_Analyzer en pitch_analyzer.h para que tenga en cuenta los nuevos umbrales y reemplazamos los valores que hasta ahora especificabamos manualmente en el código, por estas nuevas variables
> Mensaje de ayuda del programa:
> 
![mensajeAyuda](https://user-images.githubusercontent.com/65824775/116001699-0a671e00-a5f6-11eb-9709-111a3253ea6c.png)

> Probamos el programa sin especificar ningún valor. Nos esperamos por lo tanto que use los valores de por defecto. Realizamos una comparación con f0ref y obtenemos el mismo valor que si reemplazamos los umbrales creados para la ocasión por los valores especificados por defecto. Posteriormente se especifican unos valores por consola, y nuevamente coinciden con los valores que obtendríamos si reemplazasemos directamente los umbrales en el código por los especificados.

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
  
### Center Clipping
El center clipping es una técnica que trata de aumentar la intensidad de los armónicos de orden elevado, y poner a cero los instantes de tiempo en los que la señal tiene un amplitud menor, permitiendo asi una mayor robustez frente al ruido.
Hemos decidido implementar las dos variantes del clipping existentes, con o sin offset. En base a las dos fórmulas siguientes, hemos propuesto el código de debajo:
![centerClipping](https://user-images.githubusercontent.com/65824775/116004128-a6e2ed80-a601-11eb-8419-f3dda092d9f7.png)
Versión con offset:
```c
/// \TODO
  /// Preprocess the input signal in order to ease pitch estimation. For instance,
  /// central-clipping or low pass filtering may be used.
  #if 0
  float x_th = 0.00005;
  for (unsigned int n=0; n < x.size(); n++){
    if(x[n]>x_th){
      x[n] = x[n] - x_th;
    }else if(x[n]< -x_th){
      x[n] = x[n] + x_th;
    }else
    x[n] = 0;
  }
  ///DONE Center clipping implementado (con offset)
```
Versión sin offset:
```c
#if 1
  for (unsigned int n=0; n < x.size(); n++){
    if(x[n]<x_th && x[n]>-x_th){
      x[n] = 0;
    }
  }
  ///DONE Center clipping implementado (sin offset)
  #endif
```
Además, decidimos pasar los valores de estos thresholds también como parámetros por consola. Vemos que  nos sale mejor resultado cuando usamos la opción sin offset, donde nos mejora nuestra mejor puntuación en 0.03%

### Script para la optimización de thresholds
LINKS que hemos consultado para familiarizarnos con el lenguaje de Bash Shell

https://www.tutorialspoint.com/unix/unix-what-is-shell.htm

https://devhints.io/bash

Queremos aprovechar la implementación del pase de parámetros por consola en nuestro código, para diseñar un script que pruebe todas las combinaciones de los valores de estos umbrales y  tras evaluarlos en la base de datos, nos señale cuál es la mejor combinación. 
Habiendo previsto que el número de cálculos que va a tenerse que realizar una vez ejecutado el script va a ser bastante elevado, hemos creado paralelamente un script prueba.sh donde realizaremos pequeñas pruebas, valga la redundancia, para asegurarnos de cada paso del código.

Crearemos un nuevo programa, pitch_evaluate_thresholds que usaremos como alternativa al pitch_evaluate normal, para poder sacar SOLAMENTE el score final que es el único que evaluará nuestro script. 
Para ello creamos entonces un nuevo .cpp quedándonos solo con los cout que nos interesa.

![pitchEvaluate1](https://user-images.githubusercontent.com/65824775/116004320-7cddfb00-a602-11eb-8cec-3986b20c42b5.png)

Si miramos el resto del código, no hay más modificaciones que lo que se ve en la imagen de encima, partes de código comentadas para que salga en consola solo el score final.
Modificamos el meson.build para crear el nuevo programa. 

![pitchEvaluate2](https://user-images.githubusercontent.com/65824775/116004326-82d3dc00-a602-11eb-9645-81484336f302.png)

Pasamos ahora al código del propio script. Primero inicializamos los parámetros de interés y creamos un triple bucle de for para poder crear todas las combinaciones posibles entre los umbrales dentro de unos intervalos.
```c
#!/bin/bash

GETF0="get_pitch"
EVALUATE="pitch_evaluate_thresholds"

#Inicialización de los parámetros
INDICE=0

SCOREMAX=0

PMAX=0
RMAX=0
RLAGMAX=0

#Eliminamos el fichero scores en caso de que ya exista (para evitar poblemas a la hora de la evaluación)
FILE=$HOME/PAV/P3/scores
if [ -f "$FILE" ]
then
    rm $FILE
fi

#Combinación de los valores de los umbrales
for ((p_th=-15;p_th>=-40;p_th-=5))
do
    for r1_th in $(seq 0.0 .1 1) #((r1_th=0;r_th<=1;r_th+=0.05))
    do
        for rlag_th in $(seq 0.0 .1 1) #((rlag_th=0;rlag_th<=1;rlag_th+=0.05))
        do
```
Basándonos en el código de los shells facilitados, invocamos el programa get_pitch para cada audio de la base de datos con los valores de los umbrales que haya a cada vuelta.
Tras esto, evaluamos los resultados con el nuevo programa “pitch_evaluate_thresholds” y guardamos el score de cada vuelta en un fichero llamado “scores”. Tras esto, abrimos el fichero “scores” y evaluamos si el score actual es mayor al score que por el momento sea el mayor. Si es asi, el mayor score se modificara, y guardamos además los valores de los umbrales con los que se ha conseguido dicho score.

```c
#Invocamos a get_pitch para cada audio de la BD con los valores de umbrales
            for fwav in pitch_db/train/*.wav; 
            do
                ff0=${fwav/.wav/.f0}
                $GETF0 $fwav $ff0 "-p $p_th -r $r1_th -m $rlag_th" > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
            done
            #Evaluamos el rendimiento de nuestro pitch_analyzer, y guardamos el score final en el fichero 'scores'
            $EVALUATE pitch_db/train/*.f0ref >> $FILE

            scores=($(cat scores)) #Abrimos el ficheros scores

            if [[ ${scores[INDICE]} > $SCOREMAX ]]
                then
                    SCOREMAX=${scores[INDICE]}
                    PMAX=$p_th
                    RMAX=$r1_th
                    RLAGMAX=$rlag_th
            fi
            INDICE=$((INDICE + 1))
            echo "$INDICE"
        done
    done   
done
```
Finalmente mostramos el resultado final en consola indicando el score máximo alcanzado y los valores de los umbrales con los que se alcanzo.

```c
echo "El score más alto es de $SCOREMAX% y se da para los siguientes valores de umbrales: "
echo "POTENCIA: $PMAX     AUTOCORRELACIÓN (en 1): $RMAX      AUTOCORRELACIÓN (en pitch): $RLAGMAX"
```
Se hace el script ejecutable utilizando el comando chmod +x y el resultado que se ve en consola es el siguiente:
![resultadoScript](https://user-images.githubusercontent.com/65824775/116004490-291fe180-a603-11eb-9164-f495cdd11d6a.png)

Realizar un script de estas magnitudes está bien, pero el peso computacional es elevado y el tiempo de ejecución también (todo depende de qué valores escojamos para los intervalos en el for). Tambien puede resultar en que nos adaptemos demasiado a esta base de datos, y que si nos evaluamos en otra base de datos, (o en una parte no visible de esta misma BD), el score final acabe por decrementarse.

### Implementación ventana de Hamming

![eqHamming](https://user-images.githubusercontent.com/65824775/116004532-61272480-a603-11eb-91ea-dcc5b4004a45.png)

Siguiendo la formula anterior se implementa la ventana de Hamming, aunque no se obtiene un mejor resultado de F-Score:

```c
case HAMMING:
      /// \TODO Implement the Hamming window
      for (unsigned int i = 0; i < frameLen; i++)
      {
        window[i] = 0.54 - 0.46 * cos((2 * M_PI * i) / (frameLen - 1));
      }
        /// \DONE Hamming window implemented
      //break;
```
### Implementación filtro de Mediana

Link utilizado de referencia para la implementación:
http://fourier.eng.hmc.edu/e161/lectures/smooth_sharpen/node2.html

Tras probarse varias longitudes del filtro de mediana, se obtiene la mejor relación entre propagación de errores y minimización de gross error (visible en los spikes del pitch de las gráficas comparativas con el pitch de Wavesurfer) con una longitud de 3:
```c
 /// \TODO
  /// Postprocess the estimation in order to supress errors. For instance, a median filter
  /// or time-warping may be used.
#if 1
  for (unsigned int i = 1; i < f0.size() - 1; i++)
  {
    vector<float> arr;
    arr.push_back(f0[i]);
    arr.push_back(f0[i + 1]);
    arr.push_back(f0[i - 1]);

    //sorting array
    if (arr[1] < arr[0])
      swap(arr[0], arr[1]);

    if (arr[2] < arr[1])
    {
      swap(arr[1], arr[2]);
      if (arr[1] < arr[0])
        swap(arr[1], arr[0]);
    }
    f0[i] = arr[1];
  }
  /// \DONE Implementado filtro de 3 posiciones de mediana.
```
Gráfica del pitch sin filtro de mediana:

<img src="https://user-images.githubusercontent.com/65824775/116004697-2ec9f700-a604-11eb-9f1d-13ae206e7e49.png" width="500">


Gráfica del pitch con filtro de mediana:

<img src="https://user-images.githubusercontent.com/65824775/116001175-7f852400-a5f3-11eb-95a4-122ebcbdf9ac.png" width="500">


Evaluación *ciega* del detector
-------------------------------

Antes de realizar el *pull request* debe asegurarse de que su repositorio contiene los ficheros necesarios
para compilar los programas correctamente ejecutando `make release`.

Con los ejecutables construidos de esta manera, los profesores de la asignatura procederán a evaluar el
detector con la parte de test de la base de datos (desconocida para los alumnos). Una parte importante de
la nota de la práctica recaerá en el resultado de esta evaluación.
