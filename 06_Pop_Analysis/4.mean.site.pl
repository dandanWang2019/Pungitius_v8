#! /usr/bin/perl

use strict;
use warnings;

my %h;
$h{autosome} = 406173618;
$h{lg12_sdr} = 17767635;
$h{lg12_par} = 16749860;
$h{lg22} = 22782145;


my @lg12 =glob("./LG12_split/*sites.pi");
my @autosome = glob("./*/v8_autosome*sites.pi");
my @lg22 = glob("./*/v8_LG22*sites.pi");
my %pi;

open O, "> $0.sites.txt";
print O "Population\tSex\tAutosome_pi\tLG12_SDR_pi\tLG12_PAR_pi\tLG22\n"; 
for my $auto (@autosome){
    chomp $auto;
    $auto =~ /.*\/(.*)\.(.*)\.(.*)\.site\.sites/;
    my $type = $1;
    my $p = $2;
    my $g = $3;
    open IN, "< $auto";
    #my ($sum, $n);
    my $sum;
    while(<IN>){
	chomp;
	next if/^CHROM/;
	my $pi = (split/\s+/)[-1];
	next if($pi =~ /nan/);
	$sum += $pi;
    }
    close IN;
    $pi{$p}{autosome}{$g} = $sum/$h{autosome};
#    print "$pi{$p}{autosome}{Female}";exit;
}


for my $lg12 (@lg12){
    chomp $lg12;
    $lg12 =~ /.*\/LG12\.(.*)\.(.*)\.(.*).sites/;
    my $p = $1;
    my $g = $2;
    my $type = $3;
    open I, "< $lg12";
    my $sum;
    while(<I>){
	chomp;
	next if/^CHROM/;
	my $pi = (split/\s+/)[-1];
	next if($pi =~ /nan/);
	$sum += $pi;
    }
    close I;
    if($type eq "sdr"){
	$pi{$p}{lg12_sdr}{$g} = $sum/$h{lg12_sdr};
    }elsif($type eq "par"){
	$pi{$p}{lg12_par}{$g} = $sum/$h{lg12_par};
    }
}

for my $lg22 (@lg22){
    chomp $lg22;
    $lg22 =~ /.*\/v8_LG22\.(.*)\.(.*)\.site\.sites/;
# v8_LG22.FIN-HEL.Male.site.sites.pi
    my $p = $1;
    my $g = $2;
    open IN, "< $lg22";
    my $sum;
    while(<IN>){
        chomp;
        next if/^CHROM/;
        my $pi = (split/\s+/)[-1];
        next if($pi =~ /nan/);
        $sum += $pi;
    }
    close IN;
    $pi{$p}{lg22}{$g} = $sum/$h{lg22};
}

for my $k (sort keys %pi){
   print O "$k\tmale\t$pi{$k}{autosome}{Male}\t$pi{$k}{lg12_sdr}{Male}\t$pi{$k}{lg12_par}{Male}\t$pi{$k}{lg22}{Male}\n";
   print O "$k\tfemale\t$pi{$k}{autosome}{Female}\t$pi{$k}{lg12_sdr}{Female}\t$pi{$k}{lg12_par}{Female}\tNA\n";
}
close O;
