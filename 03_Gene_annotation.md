## De novo prediction

In this step, we will predict protein-coding genes based on the gene structure using three software.

``` bat
Notes: Gene prediction was based on genome.maked.fa, which was masked repeat sequence.
```

### Run Augustus

Training gene sets for P. pungitius following the Augustus mannual:
https://vcru.wisc.edu/simonlab/bioinformatics/programs/augustus/docs/tutorial2015/training.html

Split genome.masked.fa into `chr.masked.fa`:

perl 01.split.fa.pl genome.masked.fa

Predict genes using Augustus:

``` bat
augustus --species=pungitius chr.masked.fa > genome.augustus.fa
```

### Run Glimmerhmm

``` bat
glimmerhmm_linux_x86_64 chr.masked.fa -d /software/glimmerhmm/GlimmerHMM/trained_dir/zebrafish
```

### Run Genscan

``` bat
genescan HumanIso.smat chr.masked.fa
```

## Homology prediction

 In this step, we will predict protein coding genes based on the homology sequence from 5 species using GeMoMa.

``` bat
java -jar /software/gemoma/GeMoMa-1.6.1.jar CLI GeMoMaPipeline threads=20 t=homology/ref.genome.fa s=own a=homology/ref.genomic.gff g=chr.masked.fa outdir=GeMoMa/genome.results AnnotationFinalizer.r=NO tblastn=false
```

## Transcriptome-based prediciton

In this step, we will annotate genes based on the transcriptome data of ninespined stickleback.

### Step1: Assemble transcriptome using abinitio method:

This step will assemble transcriptome without any reference genome.

Assemble transcriptome without reference:

``` bat
Trinity --seqType fq --max_memory 70G --left SRR10811715_1.flt.fastq.gz,SRR10811716_1.flt.fastq.gz,SRR10811717_1.flt.fastq.gz,SRR10811718_1.flt.fastq.gz,SRR10811719_1.flt.fastq.gz --right SRR10811715_2.flt.fastq.gz,SRR10811716_2.flt.fastq.gz,SRR10811717_2.flt.fastq.gz,SRR10811718_2.flt.fastq.gz,SRR10811719_2.flt.fastq.gz --trimmomatic --CPU 8
```

Use PASA to annotate transcriptome.

### Step2: Assemble transcriptome using reference based method:

This step will assemble transcriptome with the reference genome (v7).

Build index:

``` bat
hisat2-build -p 10 genome.fa idx
```

Map clean reads to the reference genome:

``` bat
hisat2 --dta -x idx -p 36 -1 ./$i\_1.fq.gz -2 ./$i\_2.fq.gz |samtools sort -@ 10 > $i.bam &
```

Combine bam files:

``` bat
samtools merge -@ 10 merge.bam T01.bam T02.bam T03.bam T04.bam T05.bam
```

Assemble transcriptome:

``` bat
stringtie -p 10 -o stringtie_merged.gtf merge.bam
```

#### TransDecoder predict ORF

Covert gtf to gff:

``` bat
perl gtf_to_alignment_gff3.pl stringtie_merged.gtf > stringtie_merged.gff
```

Predict ORF:

``` bat
TransDecoder.LongOrfs -t transcripts.fasta
```

Predict coding region:

``` bat
TransDecoder.Predict -t transcripts.fasta --retain_blastp_hits blastp.result
```

Generate annotated `.gff` file
``` bat
cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3 \
transcripts.gff3 transcripts.fasta > transcripts.fasta.transdecoder.genome.gff3
```

## Combine annotation using EVM

Split prediction from all software into each chromosome:

``` bat
/EvmUtils/partition_EVM_inputs.pl --genome chr.masked.fa --gene_predictions gene_predictions.gff3 --transcript_alignments transcript_alignments.gff3 --segmentSize 500000 --overlapSize 10000 --partition_listing partitions_list.out
```
Generate commands:

/EvmUtils/write_EVM_commands.pl --genome chr.masked.fasta --gene_predictions gene_predictions.gff3 --transcript_alignments transcript_alignments.gff3 --weights `pwd`/weights.txt --output_file_name evm.out partitions_list.out > commands.list

Run EVM and save log file:

/EvmUtils/execute_EVM_commands.pl commands.list | tee run.log

COmbine `.gff` file of each chromosome reaults:

/EvmUtils/convert_EVM_outputs_to_GFF3.pl --partitions partitions_list.out --output_file_name evm.out --genome chr.masked.fasta