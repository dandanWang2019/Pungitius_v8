#! /usr/bin/perl

use strict;
use warnings;

my $lg12 = shift;

$lg12 =~ /.*(v8_LG12.*ale)\.(.*)\.pi/;
my $pop = $1;
my $type = $2;

if($type =~ /sites/){
    open IN, "< $lg12";
    open O1, "> $pop.sdr.sites.pi";
    open O2, "> $pop.par.sites.pi";
    print O1 "CHROM\tPOS\tPI\n";
    print O2 "CHROM\tPOS\tPI\n";
    while(<IN>){
	chomp;
	my @a = split/\s+/;
	next if /^CHROM/;
	if($a[1] > 17767635){
	    print O2 "$_\n";
	}else{
	    print O1 "$_\n";
	}
    }
    close IN;
    close O1;
    close O2;
}elsif($type =~ /window/){
    open IN, "< $lg12";
    open O3, "> $pop.sdr.window.pi";
    open O4, "> $pop.par.window.pi";
    print O3 "CHROM\tBIN_START\tBIN_END\tN_VARIANTS\tPI\n";
    print O4 "CHROM\tBIN_START\tBIN_END\tN_VARIANTS\tPI\n";
    while(<IN>){
	chomp;
	my @a = split/\s+/;
	next if/^CHROM/;
	if($a[2] > 17767635){
	    print O4 "$_\n";
	}else{
	    print O3 "$_\n";
	}
    }
    close IN;
    close O3;
    close O4;
}
