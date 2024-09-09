#! /usr/bin/perl

use strict;
use warnings;


my @lg12 =glob("./LG12_split/*windowed.pi");
my @autosome = glob("./*/v8_autosome*windowed.pi");
my @lg22 = glob("./*/v8_LG22*windowed.pi");
my %pi;

open O, "> $0.txt";
print O "Population\tSex\tAutosome_pi\tLG12_SDR_pi\tLG12_PAR_pi\tLG22_pi\n"; 
for my $auto (@autosome){
    chomp $auto;
    $auto =~ /.*\/(.*)\.(.*)\.(.*)\.100k/;
    my $type = $1;
    my $p = $2;
    my $g = $3;
    open IN, "< $auto";
    my ($sum, $n);
    #my $sum;
    while(<IN>){
	chomp;
	next if/^CHROM/;
	my $pi = (split/\s+/)[-1];
	next if($pi =~ /nan/);
	$sum += $pi;
	$n++;
    }
    close IN;
    $pi{$p}{autosome}{$g} = $sum/$n;
}


for my $lg12 (@lg12){
    chomp $lg12;
    $lg12 =~ /.*\/v8_LG12_(.*)\.(.*)\.(.*)\.100k.window/;
    my $p = $2;
    my $g = $3;
    my $type = $1;
    open I, "< $lg12";
    my ($sum, $n);
    while(<I>){
	chomp;
	next if/^CHROM/;
	my $pi = (split/\s+/)[-1];
	next if($pi =~ /nan/);
	$sum += $pi;
	$n++;
    }
    close I;
#    print "$type";exit;
    if($type eq "SDR"){
	$pi{$p}{lg12_sdr}{$g} = $sum/$n;
    }elsif($type eq "PAR"){
	$pi{$p}{lg12_par}{$g} = $sum/$n;
    }else{next;
    }
}

for my $lg22 (@lg22){
    chomp $lg22;
        # v8_LG22.FIN-HEL.Male.100k.windowed.pi
   $lg22 =~ /.*\/(.*)\.(.*)\.(.*)\.100k/;
    my $type = $1;
    my $p = $2;
    my $g = $3;
    open IN, "< $lg22";
    my ($sum, $n);
    #my $sum;
    while(<IN>){
        chomp;
        next if/^CHROM/;
        my $pi = (split/\s+/)[-1];
        next if($pi =~ /nan/);
        $sum += $pi;
        $n++;
    }
    close IN;
    $pi{$p}{lg22}{$g} = $sum/$n;
}
    
for my $k (sort keys %pi){
   print O "$k\tmale\t$pi{$k}{autosome}{Male}\t$pi{$k}{lg12_sdr}{Male}\t$pi{$k}{lg12_par}{Male}\t$pi{$k}{lg22}{Male}\n";
   print O "$k\tfemale\t$pi{$k}{autosome}{Female}\t$pi{$k}{lg12_sdr}{Female}\t$pi{$k}{lg12_par}{Female}\tNA\n";
}
close O;
