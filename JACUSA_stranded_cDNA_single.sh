#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=30G

module load java

export INP1=$1
export OUT=$2
#-RRDs-----------

java -Xmx20g -jar /home/cdieterich/software/JACUSA_one_sample_v1.0.0.jar call-1 -s -c 5 -P U -p 10 -W 1000000 -T 1 -a D,M,Y -r ${OUT} ${INP1}


