#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "perl Ks_chr_pair.pl H.tub_genome_chr.pep.gff H.tub_genome_chr.pep.collinearity.axt.KaKs > H.tub_genome_chr.pep.collinearity.axt.KaKs.chr_pair\n";

my %gene2chr;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	my ($chr, $gene) = split(/\t/, $_);
	$gene2chr{$gene} = $chr;
}
close IN;

open IN, "<$ARGV[1]" or die "$!\n";
while (<IN>) {
	my @t = split(/\t/, $_);
	if ($t[0] =~ /(\S+?)\&(\S+)/) {
		my $chr1 = $gene2chr{$1};
		my $chr2 = $gene2chr{$2};
		$t[0] = "$chr1\&$chr2";
		$t[0] = "$chr2\&$chr1" if $chr2 lt $chr1;
		print join("\t", @t);
	} else {
		print join("\t", @t);
	}
}
close IN;
