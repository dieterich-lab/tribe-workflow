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

### Expected results

Every entry in *bams_for_JACUSA.txt* e.g.

```
/somewhere/K002000078_52278_HISATmapping/Aligned.out.bam        day30_cntrl
```

will be processed to generate some new files such as:

```
K002000078_52278_HISATmapping.bam (soft link)
K002000078_52278_HISATmapping.bam.bai (soft link)
K002000078_52278_HISATmapping_uniq.bam
K002000078_52278_HISATmapping_uniq_rmdup.bam
```
and the respective comparisons.

## Downstream processing

In this example, we will just concentrate on RNA-RNA comparisons to discover *RRDs*

### collect A->I events from JACUSA call2 output

```
INP="call2_condition1_condition2"
PREFIX=${INP}"_A2G"
COND1=""
COND2=""

cat ${INP} |perl ~/scripts/JACUSA_to_TRIBE.pl 3 3 > ${INP}"_A2G"
```

awk '($3~/exon/){print;}($3~/utr/){print;}($3~/CDS/){print;}($3~/codon/){print;}' /biodb/genomes/homo_sapiens/GRCh38_85/GRCh38.85.gtf > annotation_85.gtf

srun bedtools intersect -a ${PREFIX} -s -b annotation_85.gtf -loj > ${PREFIX}"_sense.txt"

srun bedtools intersect -a ${PREFIX} -S -b annotation_85.gtf -loj > ${PREFIX}"_antisense.txt"

 annotate JACUSA - how many conditions.
perl ~/scripts/annotateJACUSAsites.pl ${PREFIX}"_sense.txt" 3 3

R
~/scripts/DownStreamTribe_JACUSA.R ${PREFIX}"_sense.txt_one_gene_processed_sense.txt" ${PREFIX}"_sense.txt_one_site_processed_sense.txt"  GFP_3 GS_3

VEP - produce output - 1 182712 182712 A/C 1

Output for Sequence generation

INP="call2_GFP_GS"
PREFIX=${INP}"_A2G"
COND1=""
COND2=""

cat ${INP} |perl ~/scripts/JACUSA_to_TRIBE.pl 3 3 > ${INP}"_A2G"

