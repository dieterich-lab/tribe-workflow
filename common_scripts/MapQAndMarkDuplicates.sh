#!/bin/bash

export INP=$1

samtools view -q 20 -b ${INP} > ${INP%.bam}"_uniq.bam"
mkdir -p "/tmp/"${INP%.bam}
java -Xmx10g -Djavaio.tmpdir="/tmp/"${INP%.bam} -jar /biosw/picard-tools/2.5.0/picard.jar MarkDuplicates INPUT=${INP%.bam}"_uniq.bam" OUTPUT=${INP%.bam}"_uniq_rmdup.bam" METRICS_FILE=${INP%.bam}"_uniq_rmdup.metric" ASSUME_SORTED=TRUE TMP_DIR="/tmp/"${INP%.bam}
rm -f -r "/tmp/"${INP%.bam}
samtools index ${INP%.bam}"_uniq_rmdup.bam"
