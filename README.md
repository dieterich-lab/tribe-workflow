# Tentative TRIBE / editing workflow

The idea of this workflow is to prepare input for JACUSA call-2
from HISAT2 alignment bam files using a sample sheet, which resembles the cufflinks one.
Please bear in mind that the current workflow only handles stranded RNA-seq data (fr-firststrand).

It is important to understand that two types of sequencing data comparisons could be made

* RNA-DNA comparisons (if genomics sequencing data is available)
* RNA-RNA comparisons (classical TRIBE; ctrl condition vs condition of interest)

> The respective workflows are found in
> the RDD_workflow subfolder <https://github.com/dieterich-lab/tribe-workflow/tree/master/RDD_workflow> and
> the RRD_workflow subfolder <https://github.com/dieterich-lab/tribe-workflow/tree/master/RRD_workflow>

## Basic steps

Generally, all BAM files will be pre-processed according to the procedure detailed below

1. Filter read mapping by mapping quality MapQ (>=20)
2. Mark Duplicates (with picard tools) 
3. Generate new bam files and index files
4. Call JACUSA on pairwise comparisons of conditions "call-2"

### Expected results

Every entry in a sample sheet *bams_for_JACUSA.txt* e.g.

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

If we did a DNA-RNA comparison in Drosophila Schneider cells
using publicly available data from *Mechanistic Implications of Enhanced Editing by a HyperTRIBE RNA-binding protein*
<https://www.ncbi.nlm.nih.gov/pubmed/29127211>

### collect A->I events from JACUSA call2 output

```
INP="call2_condition1_condition2"
PREFIX=${INP}"_A2G"
COND1=""
COND2=""

cat ${INP} |perl ~/scripts/JACUSA_to_TRIBE.pl 3 3 > ${INP}"_A2G"
```

### Prepare reference annotation and overlap with JACUSA predictions

```
awk '($3~/exon/){print;}($3~/utr/){print;}($3~/CDS/){print;}($3~/codon/){print;}' /biodb/genomes/homo_sapiens/GRCh38_85/GRCh38.85.gtf > annotation_85.gtf

srun bedtools intersect -a ${PREFIX} -s -b annotation_85.gtf -loj > ${PREFIX}"_sense.txt"

srun bedtools intersect -a ${PREFIX} -S -b annotation_85.gtf -loj > ${PREFIX}"_antisense.txt"
```

### annotate JACUSA - how many conditions.

```
perl ./annotateJACUSAsites.pl ${PREFIX}"_sense.txt" 3 3
```

### invoke R script to produce xlsx and VEP formatted output

```
./DownStreamTribe_JACUSA.R ${PREFIX}"_sense.txt_one_gene_processed_sense.txt" ${PREFIX}"_sense.txt_one_site_processed_sense.txt"  GFP_3 GS_3
```


