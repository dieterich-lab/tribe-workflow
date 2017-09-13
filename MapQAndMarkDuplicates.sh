#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=20G

export INP=$1

module unload java
module load java/1.8.0_102
module load samtools

samtools view -q 20 -b ${INP} > ${INP%.bam}"_uniq.bam"
mkdir -p "/scratch/cdieterich/"${INP%.bam}
java -Xmx10g -Djavaio.tmpdir="/scratch/cdieterich/"${INP%.bam} -jar /biosw/picard-tools/2.5.0/picard.jar MarkDuplicates INPUT=${INP%.bam}"_uniq.bam" OUTPUT=${INP%.bam}"_uniq_rmdup.bam" METRICS_FILE=${INP%.bam}"_uniq_rmdup.metric" ASSUME_SORTED=TRUE TMP_DIR="/scratch/cdieterich/"${INP%.bam}
rm -f -r "/scratch/cdieterich/"${INP%.bam}
samtools index ${INP%.bam}"_uniq_rmdup.bam"
