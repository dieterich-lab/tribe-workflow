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

### collect A->I events from JACUSA call2 output (DNA vs RNA)

```
INP="call2_DNA_E488Q_ADARcd_s2"

cat ${INP} |perl RDD_workflow/JACUSA_to_TRIBE_gDNA.pl 1 2 > ${INP}"_A2G"
```

### Prepare reference annotation and overlap with JACUSA predictions

```
INP="/biodb/genomes/drosophila_melanogaster/BDGP6_85/BDGP6.85.gtf";
module load bedtools

#retrieve exonic elements
awk '($3~/exon/){print;}($3~/utr/){print;}($3~/CDS/){print;}($3~/codon/){print;}' ${INP} > annotation_85.gtf

#generate introns
awk '($3~/exon/){print;}' ${INP} >exon_annotation_85.gtf
awk '($3~/gene/){print;}' ${INP} >gene_annotation_85.gtf
sort -k1,1 -k4,4n exon_annotation_85.gtf > exon_sorted.gtf
srun bedtools merge -i exon_sorted.gtf -s > exon_merged_85.gtf
srun bedtools subtract -a gene_annotation_85.gtf -b exon_merged_85.gtf| awk 'BEGIN{FS="\t";}{gsub("gene","intron",$3); print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9;}' > intronic_merged_85.gtf

#merge exonic and intronic annotation
cat annotation_85.gtf intronic_merged_85.gtf |sort -k1,1 -k4,4n >tempo
mv tempo final_annotation_85.gtf

srun bedtools intersect -a ${PREFIX} -s -b final_annotation_85.gtf -loj > ${PREFIX}"_sense.txt"
```

### annotate JACUSA - how many conditions.

```
perl RDD_workflow/annotateJACUSAsites.pl ${PREFIX}"_sense.txt" 1 2
```

### invoke R script to produce xlsx and VEP formatted output

```
module load R
srun RDD_workflow/DownStreamTribe_JACUSA_Yves.R ${PREFIX}"_sense.txt_one_gene_processed_sense.txt" ${PREFIX}"_sense.txt_one_site_processed_sense.txt"  DNA_1 E488Q_ADARcd_s2_2
```

## Dependencies

1. UNIX commandline shell (bash)
2. JAVA 1.8+ 
3. Picard tools for MarkDuplicates <http://broadinstitute.github.io/picard>
4. JACUSA release 1.2.2 <https://github.com/dieterich-lab/JACUSA/releases/tag/1.2.2>

