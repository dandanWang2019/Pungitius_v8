#! /usr/bin/perl

use strict;
use warnings;

my @vcf = glob("./00.vcf/*gz");

my $sample = "v7_v8_sample_sex.tsv";

my @sp;


open IN, "< $sample";
while(<IN>){
    chomp;
    #next if /^\d+/;
    my @a = split/\s+/;
    my $pop;
    if($a[-2] =~ /^\d+/){
	$pop = "FIN-HEL";
    }else{
    $a[-2] =~ /(.*)\-\d+/;
    $pop = $1;
    }
    `mkdir $pop` if (! -d "./$pop");
    open L, ">> $pop.$a[-1].list";
    print L "$a[-3]\n";
    close L;
}
close IN;    

open O, "> $0.sh";
my @list = glob("./*list");
for my $list (@list){
    chomp $list;
    $list =~ /.*\/(.*)\.(.*)\.list/;
    my $p = $1;
    my $g = $2;
    #`mv $list $p`;
    for my $vcf (@vcf){
	chomp $vcf;
	$vcf =~ /.*\/(.*)\_snp.*/;
	my $chr = $1;
	if ($chr =~ /v8_LG22/){
	    print O "/projappl/project_2006483/vcftools/bin/vcftools --gzvcf $vcf --keep $p.Male.list --out $p/v8_LG22.$p.Male.site --site-pi --haploid\n";
	}elsif($chr =~ /LG12_SDR/){
	    $chr =~ /(v8\_LG12\_SDR)\_(.*)/;
	    my $type = $1;
	    my $sex = $2;
	    if($sex eq 'Male'){
	    print O "/projappl/project_2006483/vcftools/bin/vcftools --gzvcf $vcf --keep $p.$sex.list --out $p/$type.$p.$sex.site --site-pi --haploid\n";
	    }elsif($sex eq 'Female'){
		print O "vcftools --gzvcf $vcf --keep $p.$sex.list --out $p/$type.$p.$sex.site --site-pi\n";
	    }
	    }else{
	    print O "vcftools --gzvcf $vcf --keep $list --out $p/$chr.$p.$g.site --site-pi\n";
	}
    }
}
close O;
