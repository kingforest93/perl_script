#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl hap_split.fa Ht_genome_chr.fa\n";

# read chromosomes and separately output the chromosomes of each haplotype
my ($id, $hap, $seq, $file);
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	if (/^>(\S+)/) {
		$header = $1;
		if ($id =~ /(H[1-6])/) {
			$hap = $1;
			$file = "$hap\.fa";
			open OUT, ">>$file" or die "$!\n";
			print OUT ">$id\n$seq";
			close OUT;
		}
		$id = $header;
		$seq = "";
	} else {
		$seq .= $_;
	}
}
close IN;

# output the last
if ($id =~ /(H[1-6])/) {
	$hap = $1;
	$file = "$hap\.fa";
	open OUT, ">>$file" or die "$!\n";
	print OUT ">$id\n$seq";
	close OUT;
}
