#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl monoploid_split.pl Ht_monoploid_chr.fa Ht_chr_group\n";

# read Ht_monoploid_chr.fa
my %seqs;
my $chr;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	if (/^>(\S+)/) {
		$chr = $1;
	} else {
		$seqs{$chr} .= $_;
	}
}
close IN;

# output each chromosome separately
my $outdir = $ARGV[1];
mkdir $outdir if not -d $outdir;
foreach $chr (keys %seqs) {
	mkdir "$outdir/$chr" if not -d "$outdir/$chr";
	open OUT, ">$outdir/$chr/$chr\.fa" or die "$!\n";
	print OUT ">$chr\n$seqs{$chr}";
	close OUT;
}
