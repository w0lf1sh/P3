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
echo "El score más alto es de $SCOREMAX% y se da para los siguientes valores de umbrales: "
echo "POTENCIA: $PMAX     AUTOCORRELACIÓN (en 1): $RMAX      AUTOCORRELACIÓN (en pitch): $RLAGMAX"


