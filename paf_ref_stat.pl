#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "
	Description: read alignment PAF file produced by minimap2 and output the alignment coverage and divergence of each reference sequence.
	
	Author: Sen Wang, wangsen1993@163.com, 2021/3/4.

	Usage: perl paf_ref_stat.pl input.paf > output.stat
	\n";
my (%rseqs, %rde, %raln);
# read and parse paf file
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @f = split /\t/, $_;
	$raln{$f[5]} += 1;
	$_ =~ /d[ev]:f:([01]\.\d+)/;
	$rde{$f[5]} += $1;
	$rseqs{$f[5]} = "N" x $f[6] if not $rseqs{$f[5]};
	my $start = $f[7];
	my $len = $f[8] - $f[7] + 1;
	substr($rseqs{$f[5]}, $start, $len, "X" x $len);
}
close IN;
# output reference coverage
print "Reference\tLength\tCoverage\tDivergence\n";
foreach my $id (sort keys %rseqs) {
	my $aln = 0;
	while ($rseqs{$id} =~ /X/g) {
		$aln += 1;
	}
	my $len = length($rseqs{$id});
	my $cov = $aln / $len;
	my $de = $rde{$id} / $raln{$id};
	printf "%s\t%d\t%.5f\t%.5f\n", $id, $len, $cov, $de;
}
