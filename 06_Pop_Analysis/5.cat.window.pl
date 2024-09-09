#! /usr/bin/perl

use strict;
use warnings;

my @lg12 =glob("./LG12_split/*windowed.pi");
my @autosome = glob("./*/v8_autosome*windowed.pi");
my @lg22 = glob("./*/v8_LG22*windowed.pi");
my %pi;

open O, "> all.window.tsv";
print O "Chrom\tPI\tRegion\tPop\tSex\tVersion\n";

for my $lg12 (@lg12){
    chomp $lg12;
    $lg12 =~ /.*\/v8_LG12_(.*)\.(.*)\.(.*)\.100k.window/;
    my $p = $2;
    my $g = $3;
    my $type = $1;
    open I, "< $lg12";
    while(<I>){
	chomp;
	next if/^CHROM/;
	my @a = split/\s+/;
	print O "$a[0]\t$a[-1]\t$type\t$p\t$g\tv8\n"
    }
    close I;
}

for my $auto (@autosome){
    chomp $auto;
    $auto =~ /.*\/(.*)\.(.*)\.(.*)\.100k/;
    my $type = $1;
    my $p = $2;
    my $g = $3;
    open IN, "< $auto";
    while(<IN>){
	chomp;
	next if/^CHROM/;
	my @a = split/\s+/;
	print O "$a[0]\t$a[-1]\tautosome\t$p\t$g\tv8\n";
    }
    close IN;
}

for my $lg22 (@lg22){
    chomp $lg22;
        # v8_LG22.FIN-HEL.Male.100k.windowed.pi
   $lg22 =~ /.*\/(.*)\.(.*)\.(.*)\.100k/;
    my $type = $1;
    my $p = $2;
    my $g = $3;
    open IN, "< $lg22";
    while(<IN>){
	chomp;
	next if/^CHROM/;
	my @a = split/\s+/;
	print O "$a[0]\t$a[-1]\tlg22\t$p\t$g\tv8\n";
    }
    close IN;
}

close O;
