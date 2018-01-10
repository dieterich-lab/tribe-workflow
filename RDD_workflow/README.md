# Produce call2 output from JACUSA with the help of prepare_for_JACUSA_gDNA.pl

### catch A->I events from JACUSA output

```
INP="call2_DNA_E488Q_ADARcd_s2"
PREFIX=${INP}"_A2G"
COND1=$(echo $INP | cut -f2 -d _ )
COND2=$(echo $INP | cut -f3 -d _ )

cat ${INP} |perl RDD_workflow/JACUSA_to_TRIBE_gDNA.pl 1 2 > ${INP}"_A2G"

```

### overlap with annotation
```
srun bedtools intersect -a ${PREFIX} -s -b final_annotation_85.gtf -loj > ${PREFIX}"_sense.txt"
```

### annotate JACUSA - how many conditions.
```
perl RDD_workflow/annotateJACUSAsites.pl ${PREFIX}"_sense.txt" 1 2
```

### call to R - produce output such as Excel spreadsheet, VEP and BED files
```
srun RDD_workflow/DownStreamTribe_JACUSA_Yves.R ${PREFIX}"_sense.txt_one_gene_processed_sense.txt" ${PREFIX}"_sense.txt_one_site_processed_sense.txt"  ${COND1}"_1" ${COND2}"_2"
```

