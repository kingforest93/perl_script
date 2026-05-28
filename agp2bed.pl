#!/usr/bin/perl
use strict;

# parse input
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read HiC bins of contigs in BED format (HiC-Pro output) and reorder the bins according to the anchored contigs in scaffold in AGP format.

	Author: Sen Wang, wangsen1993@163.com, 2021/6/1.
	
	Usage: perl agp2bed.pl formal_500000_abs.bed gfa.cluster.agp > gfa.cluster.agp.bed
	\n";
}

# parse matrix bed file
my %ctg;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	push @{$ctg{$t[0]}}, "$t[1]\t$t[2]\t$t[3]";	
}
close IN;

# parse agp file and reorder bins
my %chr;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^ptg/;
	chomp;
	my @t = split /\t/, $_;
	next if $t[4] ne "W";
	die "Cannot get the bins of $t[5]! check $ARGV[0]!\n" if not $ctg{$t[5]};
	if ($t[8] eq "-") {
		foreach my $line (reverse @{$ctg{$t[5]}}) {
			print "$t[0]\t$line\n";
		}
	} else {
		foreach my $line (@{$ctg{$t[5]}}) {
			print "$t[0]\t$line\n";
		}
	}
}
close IN;
