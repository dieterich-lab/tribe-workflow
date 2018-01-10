#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=30G

module load java

export INP1=$1
export INP2=$2
export OUT=$3

#-RRDs------------
#CHANGE EDIT DISTANCE AGAIN
java -Xmx20g -jar /home/cdieterich/software/JACUSA_v1.2.2.jar call-2 -s -c 5 -P FR-FIRSTSTRAND,FR-FIRSTSTRAND -p 10 -W 1000000 -F 1024 --filterNM_1 5 --filterNM_2 5 -T 1 -a D,M,Y -r ${OUT} ${INP1} ${INP2}



