#!/bin/bash

#Se puede invocar otros scripts desde un script

#RUN="run_get_pitch"
#$RUN

#GETF0="get_pitch"
a=1
b=0.5
echo $a + $b | bc

echo "Bucle for funcional"
for i in $(seq 0.0 .05 10.0)
do  
    echo $i
done

#------------------------------------------------------------

#Prueba de llamada

#GETF0="get_pitch"
#P=20
#R=0.5
#M=0.6
#for fwav in pitch_db/train/*.wav; do
#    ff0=${fwav/.wav/.f0}
#    echo "$GETF0 "
#    $GETF0 $fwav $ff0 "-p $P -r $R -m $M" > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
#done

#Comprobado que sale el mismo resultado evaluar esto que si ponemos estos valores directamente
#en el código

#------------------------------------------------------------

#Creación archivo de scores.

#EVALUATE="pitch_evaluate_thresholds"
#GETF0="get_pitch"

#P=20
#R=0.5
#M=0.6

#for fwav in pitch_db/train/*.wav; do
#    ff0=${fwav/.wav/.f0}
#    echo "$GETF0"
#    $GETF0 $fwav $ff0 "-p $P -r $R -m $M" > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
#done

#$EVALUATE pitch_db/train/*.f0ref > CURRENT_SCORE

#P=40
#R=0.85
#M=0.4

#for fwav in pitch_db/train/*.wav; do
#    ff0=${fwav/.wav/.f0}
#    echo "$GETF0"
#    $GETF0 $fwav $ff0 "-p $P -r $R -m $M" > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
#done
#$EVALUATE pitch_db/train/*.f0ref >> CURRENT_SCORE

#P=30
#R=0.8
#M=0.4

#for fwav in pitch_db/train/*.wav; do
#    ff0=${fwav/.wav/.f0}
#    echo "$GETF0"
#    $GETF0 $fwav $ff0 "-p $P -r $R -m $M" > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
#done
#$EVALUATE pitch_db/train/*.f0ref >> CURRENT_SCORE

#------------------------------------------------------------


#Recorrer fichero de números

numbers=($(cat CURRENT_SCORE))
echo "Numeros: "
for i in ${numbers[@]}; do
    echo "$i"
done

#Comparaciones
M=0
N=${numbers[0]}

if [[ $M > $N ]]
    then
        echo "$M es mayor a $N"
    else
        echo "$M es menor a $N"
fi

#Buscar max en una lista de números y su indice
indice=0;
indicemax=0;
for j in ${numbers[@]}; do

    if [[ $M < $j ]]
    then
        M=$j
        indicemax=$indice
    fi
indice=$((indice + 1))
done
echo "Num. Max: $M en indice $indicemax "

#Buscar max en una lista de números y su indice
indice=1;
M=${numbers[indice]}
N=${numbers[$((indice - 1))]}

if [[ ${numbers[indice]} < ${numbers[$((indice - 1))]} ]]
    then
        echo "${numbers[indice]} es menor a ${numbers[$((indice - 1))]}"
    else
        echo "${numbers[indice]} es mayor a ${numbers[$((indice - 1))]}"
fi

