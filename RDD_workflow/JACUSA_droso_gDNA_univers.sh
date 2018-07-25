#!/bin/bash

export INP1=$1
export INP2=$2
export OUT=$3

#-RDDs-----------

#gDNA_VS_siADAR-1_2.bed
java -Xmx20g -jar JACUSA_v1.2.2.jar call-2 -s -c 5 -P UNSTRANDED,FR-FIRSTSTRAND -p 10 -W 1000000 -F 1024 --filterNM_1 5 --filterNM_2 5 -a D,M,Y,H:1 -T 1.15 -r ${OUT} ${INP1} ${INP2}
