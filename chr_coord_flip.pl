#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "perl chr_coord_flip.pl inversion_chr.len H.ann_vs_H.tub_genome_chr.pep.collinearity.filtered.Ks0.2.list.1ploid.complete > H.ann_vs_H.tub_genome_chr.pep.collinearity.filtered.Ks0.2.list.1ploid.complete.flip\n";

my %chr2len;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	my ($chr, $len) = split(/\t/, $_);
	$chr2len{$chr} = $len;
}
close IN;

open IN, "<$ARGV[1]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split(/\t/, $_);
	if ($chr2len{$t[1]}) {
		my $tem = $t[3];
		$t[3] = $chr2len{$t[1]} - $t[4];
		$t[4] = $chr2len{$t[1]} - $tem;
	} elsif ($chr2len{$t[6]}) {
		my $tem = $t[8];
		$t[8] = $chr2len{$t[6]} - $t[9];
		$t[9] = $chr2len{$t[6]} - $tem;
	}
	print join("\t", @t) . "\n";
}
close IN;
