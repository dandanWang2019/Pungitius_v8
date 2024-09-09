## map clean reads to genome.fa (v7&v8)

We will get final .bam files for each individual this step.

```bat
PL=DNBseq

ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./list)

bwa mem -t8 -M \
-R "@RG\tID:${ind}\tSM:${ind}\tPL:${PL}\tLB:${ind}\tPU:1" \
/scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
/scratch/project_2006483/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.pair1.truncated.gz \
/scratch/project_2006483/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.pair2.truncated.gz \
| samtools view -h -b \
| samtools sort -O bam -o ${ind}_PE.sort.bam

bwa mem -t8 -M \
-R "@RG\tID:${ind}\tSM:${ind}\tPL:${PL}\tLB:${ind}\tPU:1" \
/scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
/scratch/project_2006483/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.collapsed.gz \
| samtools view -h -b \
| samtools sort -O bam -o ${ind}_ME.sort.bam

samtools merge ${ind}.bam \
${ind}_PE.sort.bam \
${ind}_ME.sort.bam

rm ${ind}_PE.sort.bam
rm ${ind}_ME.sort.bam
```

### mark duplicates

```bat
ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./list)

##sort by name (-n)
samtools sort -n ./${ind}.bam -O bam -o ${ind}.nsort.bam
## label for markdup (-m) using multi-cores (-@)
samtools fixmate -@ 8 -m ${ind}.nsort.bam ${ind}.fixmate.bam
## sort by coordinates
samtools sort ${ind}.fixmate.bam -O bam -o ${ind}.fixmate.sort.bam
samtools index ${ind}.fixmate.sort.bam

# mkdir markup_bam
## mark duplicates
samtools markdup ${ind}.fixmate.sort.bam ./markup_bam/${ind}.markup.bam
samtools index ./markup_bam/${ind}.markup.bam

## mapping summary
samtools flagstat ./markup_bam/${ind}.markup.bam > ./markup_bam/${ind}.markup.bam.flagstat

## mapping stat
#bamdst -p V8_fix.bed ./markup_bam/${ind}.markup.bam -o ${ind}
#bamdst -p V8_fix.bed ./markup_bam/${ind}.markup.bam -o ${ind}
```
