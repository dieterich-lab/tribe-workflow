# Tentative TRIBE / editing workflow

The idea of this workflow is to prepare input for JACUSA call-1 and call-2
from HISAT2 alignment bam files using a sample sheet, which resembles the cufflinks one.

```
perl ./prepare_for_JACUSA.pl bams_for_JACUSA.txt
```

catch A->I JACUSA

INP="call2_GFP_GS"
PREFIX=${INP}"_A2G"
COND1=""
COND2=""

cat ${INP} |perl ~/scripts/JACUSA_to_TRIBE.pl 3 3 > ${INP}"_A2G"

