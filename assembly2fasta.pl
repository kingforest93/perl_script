#!/usr/bin/perl
use strict;
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Usage: perl assembly2fasta.pl reviewed.assembly original.fasta > reviewed.assembly.fasta

	Author: Sen Wang, wangsen1993@163.com, 2021/8/16.
	\n";
}

# parse assembly file
my (%contigs, %scaffolds);
my $num;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	if (/^>(\w+)\s(\d+)\s/) {
		$contigs{$2} = $1;
	} else {
		$num += 1;
		my @t = split /\s/, $_;
		@{$scaffolds{$num}} = @t;
	}
}
close IN;

# read contig sequence
my %seqs;
my $header;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	if (/^>(\w+)\s/) {
		$header = $1;
		$seqs{$header} = "";
	} else {
		chomp;
		$seqs{$header} .= $_;
	}
}
close IN;

# output scaffolds
foreach (sort {$a <=> $b} keys %scaffolds) {
	print ">Scaffold_$_\n";
	my $seq = "";
	my $gap = "N" x 500;
	foreach (@{$scaffolds{$_}}) {
		$seq .= $gap if $seq;
		if ($_ > 0) {
			$seq .= $seqs{$contigs{$_}};
		} else {
			$_ =~ s/-//;
			my $tem = reverse $seqs{$contigs{$_}};
			$tem =~ tr/ATCG/TAGC/;
			$seq .= $tem;
		}
	}
	print "$seq\n";
}
