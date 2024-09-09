## map clean reads to genome.fa (v7&v8)

We will get final .bam files for each individual this step.

```bat
PL=DNBseq

ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./list)

bwa mem -t8 -M \
-R "@RG\tID:${ind}\tSM:${ind}\tPL:${PL}\tLB:${ind}\tPU:1" \
/scratch/project/genomes/genome.fasta \
/scratch/project/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.pair1.truncated.gz \
/scratch/project/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.pair2.truncated.gz \
| samtools view -h -b \
| samtools sort -O bam -o ${ind}_PE.sort.bam

bwa mem -t8 -M \
-R "@RG\tID:${ind}\tSM:${ind}\tPL:${PL}\tLB:${ind}\tPU:1" \
/scratch/project/genomes/genome.fasta \
/scratch/project/Dan_Compare/project/v8/00.clean.reads/analysis_ready_add/${ind}.collapsed.gz \
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
### extract reads mapped on LG12 & LG22 for v8 mapping

We will extract reads mapped on LG12 & LG22 and remap these reads on LG12 (X chromosome) for all females.

```bat
## extract .fastq from bam files
ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./list)

samtools view -b -h -L region.bed /scratch/project/Dan_Compare/project/v8/response/06.map/markup_bam/${ind}.markup.bam > 01.bam/${ind}.LG12_LG22.bam

samtools sort -n 01.bam/${ind}.LG12_LG22.bam -O bam -o 02.sort.bam/${ind}.LG12_LG22.sorted.bam

bamToFastq -i 02.sort.bam/${ind}.LG12_LG22.sorted.bam -fq 03.reads/${ind}.LG12_LG22.fq
```

### remap reads on LG12
```bat
PL=DNBseq

ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./female_id)

bwa mem -t8 -M \
-R "@RG\tID:${ind}\tSM:${ind}\tPL:${PL}\tLB:${ind}\tPU:1" \
/scratch/project/Dan_Compare/project/v8/response/06.map/remap/v8.LG12.fa \
/scratch/project/Dan_Compare/project/v8/response/06.map_LG12/03.reads/${ind}.LG12_LG22.fq \
| samtools view -h -b \
| samtools sort -O bam -o 04.rebam/${ind}.sort.bam
```


