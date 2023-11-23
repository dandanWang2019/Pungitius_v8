## Step 1: Repeats annotation 

In this step, we will identify and classify repeat sequence in the Pungitius pungitius v8 genome.

### 1.1 Run TRF
Use TRF to identify tandem repeats in the v8 genome:

``` bat
trf genome.fa 2 5 7 80 10 50 2000 -d -h
```

Convert output file to a `.gff` file:

Perl ConvertTrf2Gff.pl genome.fa.2.5.7.80.10.50.2000.dat genome.trf.gff

### 1.2 Run RepeatMasker

Use RepeatMasker to identify repeats based on the `Actinopteri` database:

``` bat
RepeatMasker -species Actinopteri -nolow -norna -no_is -gff genome.fa -pa 40
```

### 1.3 Run RepeatModeler

Use RepeatModeler to predict repeats based on the repeats structure:

#### 1.3.1 Build database

Build a database named 'Ppun' based on the `genome.fasta` file:

``` bat
BuildDatabase -name Ppun genome.fa 2>&1 | tee 01.BuildDatabase.log
```

#### 1.3.2 Run RepeatModeler

Run RepeatModeler on the 'Ppun' database using 20 threads:

``` bat
RepeatModeler -database Ppun \
  -threads 20 \
  -engine ncbi
```

## Step 2: Predict additional repeat using LTR_Finder

This step will further identify and classify unknown repeats in the above.

### 2.1 Run LTR_Finder

Split `genome.fa` into each chromosome:

``` bat
perl 01.split.fasta.pl genome.fa
```

Run LTR_Finder to identify LTRs in each chromosome:

``` bat
for i in `*/*fa` \
    do \
        ltr_finder $i -s eukaryotic-tRNAs.fa -w 2 > ./ltr_finder_out/${i%fa}.out \
    done
```

### 2.2 Run CD-HIT

Use CD-HIT to remove redundant LTR sequence to lessen computaional efforts:

``` bat
cd-hit-est -i ltrfinder.seq.fa -o Ppun_V8.cdhit.fa -c 0.9 -n 8 -M 16000 -d 0 -T 10
```

### 2.3 Run RepeatClassifier

Split the whole file into separate .fa file:

``` bat
perl 01.split.fasta.pl Ppun_V8.cdhit.fa
```

``` bat
for i in `*/*fa` \
    do \
        RepeatClassifier -consensi $i \
    done
```

## Step 3: Combine all repeat identification results

This step will combine repeat sequence results from RepeatModeler and LTR_Finder.

``` bat
RepeatMasker -lib Ppun.v8.lib.fa.classified -pa 40 PpunV8.fa
```


