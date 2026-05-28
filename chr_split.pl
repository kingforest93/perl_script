#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl chr_split.fa Ht_genome_chr.fa\n";

# read chromosomes separately output each group of homologous chromosomes
my ($id, $chr, $seq, $file);
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	if (/^>(\S+)/) {
		my $header = $1;
		if ($id =~ /(Chr\d\d)/) {
			$chr = $1;
			$file = "$id\.fa";
			mkdir $chr if not -d $chr;
			open OUT, ">$chr/$file" or die "$!\n";
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
if ($id =~ /(Chr\d\d)/) {
	$chr = $1;
	$file = "$id\.fa";
	mkdir $chr if not -d $chr;
	open OUT, ">$chr/$file" or die "$!\n";
	print OUT ">$id\n$seq";
	close OUT;
}
