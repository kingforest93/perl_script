#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "perl fa2gc.pl Ht_genome_ctg_v1.fa > Ht_genome_ctg_v1.fa.GC\n";

my ($gc, $len);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>/) {
		next;
	} else {
		$len += length($_);
		while (/[GC]/g) {
			$gc += 1
		}
	}
}
close IN;

printf "Total length: %d\nGC percentage: %.2f\n", $len, $gc / $len * 100;
