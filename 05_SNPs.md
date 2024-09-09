## SNP calling for v7&v8 genome

### Variants calling for each individual

```bat
ind=$(sed -n ${SLURM_ARRAY_TASK_ID}p ./list)

gatk --java-options "-Xmx4g" HaplotypeCaller \
-R /scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
-I /scratch/project_2006483/Dan_Compare/project/v8/response/06.map_v7/markup_bam/${ind}.markup.bam \
-O 01.gvcf/${ind}.gvcf.gz \
-ERC GVCF
```

### Combine individual-GVCF to chromosome-level GVCF
```bat
LG=$(sed -n ${SLURM_ARRAY_TASK_ID}p LG.list)

gatk --java-options "-Xmx30g" CombineGVCFs \
-R /scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
--intervals ${LG} \
--variant ./01.gvcf/*.gvcf.gz \
-O 02.combineGVCF/${LG}.gvcf.gz
```

### assign genotypes for each sites and convert GVCF to VCF
```bat
LG=$(sed -n ${SLURM_ARRAY_TASK_ID}p LG.list)

gatk --java-options "-Xmx30g" GenotypeGVCFs \
-R /scratch/project_2006483/genomes/genome.fasta \
--intervals ${LG} \
-V ./02.combineGVCF/${LG}.gvcf.gz \
-O ./03.genotypeGVCF/${LG}.vcf.gz
```

### Get SNPs from variant sets
```bat
LG=$(sed -n ${SLURM_ARRAY_TASK_ID}p LG.list)

gatk --java-options "-Xmx40g" SelectVariants \
-R /scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
-V 03.genotypeGVCF/v7_${LG}.vcf.gz \
-O 05.snp/v7_${LG}.snp.vcf.gz \
--select-type-to-include SNP

gatk --java-options "-Xmx40g" SelectVariants \
-R /scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
-V 03.genotypeGVCF/v7_${LG}.vcf.gz \
-O 05.indel/v7_${LG}.indel.vcf.gz \
--select-type-to-include INDEL
```

### HardFilter
```bat
LG=$(sed -n ${SLURM_ARRAY_TASK_ID}p LG.list)

gatk --java-options "-Xmx40g" VariantFiltration \
-R /scratch/project_2006483/genomes/genome.fasta \
-V 05.snp/${LG}.snp.vcf.gz \
-O 06.hardFilter/${LG}.snp.HDflt.vcf.gz \
--filter-name "my_snp_filter" \
--filter-expression "MQRankSum < -12.5 || FS > 60.0 || ReadPosRankSum < -8.0 || MQ < 40.0 || QD < 2.0" \


gatk --java-options "-Xmx40g" VariantFiltration \
-R /scratch/project_2006483/genomes/v7_ENA/NSPV7.GCA_902500615.3.fasta \
-V 05.indel/v7_${LG}.indel.vcf.gz \
-O 06.hardFilter/v7_${LG}.indel.HDflt.vcf.gz \
--filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
--filter-name "my_indel_filter"


## delete marked with filter flag generated last step
perl remove.hdfilter.pl --input 06.hardFilter/v7_${LG}.snp.HDflt.vcf.gz --out 06.hardFilter/v7_${LG}.snp.HDflted.vcf.gz --type SNP --marker my_snp_filter --multi

perl remove.hdfilter.pl --input	06.hardFilter/v7_${LG}.indel.HDflt.vcf.gz --out 06.hardFilter/v7_${LG}.indel.HDflted.vcf.gz --type INDEL --marker my_indel_filter
```

### Manually Filter
Get final SNP set for downstream analysis

```bat
LG=$(sed -n ${SLURM_ARRAY_TASK_ID}p LG.list)

bcftools view 06.hardFilter/${LG}.snp.HDflted.vcf.gz \
| vcftools --vcf - --minGQ 20 --minQ 30 --min-meanDP 3 --max-meanDP 35 \
--maf 0.05 --remove-indels --max-missing 0.2 --exclude-bed repeat.bed \
--recode --recode-INFO-all --out ${LG} -c \
| bcftools view -Oz -o 07.flt/${LG}_snp_flted.vcf.gz
```

