# Tentative TRIBE / editing workflow

The idea of this workflow is to prepare input for JACUSA call-1 and call-2
from HISAT2 alignment bam files using a sample sheet, which resembles the cufflinks one.

```
perl ./prepare_for_JACUSA.pl bams_for_JACUSA.txt
```

## Basic steps

The command line call above will do the following

1. Filter read mapping by mapping quality MapQ (>=20)
2. Mark Duplicates (with picard tools) 
3. Generate new bam files and index files
4. Call JACUSA on individual conditions "call-1"
5. Call JACUSA on pairwise comparisons of conditions "call-2"

catch A->I JACUSA

INP="call2_GFP_GS"
PREFIX=${INP}"_A2G"
COND1=""
COND2=""

cat ${INP} |perl ~/scripts/JACUSA_to_TRIBE.pl 3 3 > ${INP}"_A2G"

