## Step1: RNAmmer

rRNA genes were identified using RNAmmer:

``` bat
rnammer -S euk -m lsu,ssu,tsu -f rRNA.fasta -h rRNA.hmmreport -xml rRNA.xml -gff rRNA.gff < ./genome.fa
```

## Step2: tRNAscan-SE

tRNA genes were predicted using tRNSscan-SE:

``` bat
tRNAscan-SE genome.fa -o tRNA.out -f tRNA.ss -m tRNA.stats
```

## Step3: Infernal

snRNA and miRNA genes were identified using Infernal.

Split `genome.fa` into chr.fa for each chromosome:

``` bat
perl 01.split.fa.pl genome.fa
```

Identify for each chromosome:

``` bat
for i in `*/*fa` \
do \
    cmscan -Z 0.000978 --cut_ga --rfam --nohmmonly --tblout $i.tblout --fmt 2 --clanin ./Rfam/Rfam.clanin ./Rfam/Rfam.cm $i > $i.cmscan \
done
```

Covert .tblout to `.gff3` file:

perl infernal-tblout2gff.pl --cmscan --fmt2 $i.tblout > $i.infernal.ncRNA.gff3

