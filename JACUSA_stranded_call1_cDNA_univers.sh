#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=30G

module load java

export INP1=$1
export OUT=$2
#-RRDs------------

java -Xmx20g -jar /home/cdieterich/software/JACUSA_v1.2.0.jar call-1 -s -c 5 -P FR-SECONDSTRAND -p 10 -W 1000000 --filterNM_1 5 -T 1 -a D,M,Y -r ${OUT} ${INP1}

#OK.. we should produce EnsEMBL variant format
#1 182712 182712 A/C 1
#2 265023 265023 C/T 1
#3 319781 319781 A/- 1
#19 110748 110747 -/T 1
#1 160283 471362 DUP 1
#1 1385015 1387562 DEL 1

#bla,bla
