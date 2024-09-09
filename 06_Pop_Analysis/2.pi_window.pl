#! /usr/bin/perl

use strict;
use warnings;

my @vcf = glob("./00.vcf/*vcf");


open O, "> $0.sh";
my @list = glob("./*list");

for my $list (@list){
    chomp $list;
    $list =~ /.*\/(.*)\.(.*)\.list/;
    my $p = $1;
    my $g = $2;
    for my $vcf (@vcf){
	chomp $vcf;
	$vcf =~ /.*\/(.*)\_snp.*/;
	my $chr = $1;
	next if($chr =~ /ctg/);
	if ($chr =~ /v8_LG22/){
	    print O "/projappl/project_2006483/vcftools/bin/vcftools --vcf $vcf --keep $p.Male.list --out $p/v8_LG22.$p.Male.100k --window-pi 100000 --haploid\n";
	}elsif($chr =~ /v8_LG12_SDR/){
	    $chr =~ /(v8\_LG12\_SDR)\_(.*)/;
	    my $type = $1;
	    my $sex = $2;
	    if($sex eq 'Male'){
		print O "/projappl/project_2006483/vcftools/bin/vcftools --vcf $vcf --keep $p.Male.list --out $p/$type.$p.Male.100k --window-pi 100000 --haploid\n";
	    }elsif($sex eq 'Female'){
		print O "vcftools --vcf $vcf --keep $p.$sex.list --out $p/$type.$p.$sex.100k --window-pi 100000\n";
	    }
	}else{
	    print O "vcftools --vcf $vcf --keep $list --out $p/$chr.$p.$g.100k --window-pi 100000\n";
	}
#	print O "vcftools --gzvcf $vcf --keep $list --out $p/$chr.$p.$g.100k --window-pi 100000\n"; # Window.LG16.FIN-HEL.10k.windowed.pi
    }
}
close O;
