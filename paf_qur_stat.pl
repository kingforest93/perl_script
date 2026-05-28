#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "
	Description: read alignment PAF file produced by minimap2 and output the alignment coverage and divergence of each qurey sequence.
	
	Author: Sen Wang, wangsen1993@163.com, 2021/3/4.

	Usage: perl paf_qur_stat.pl input.paf > output.stat
	\n";
my (%qaln, %qcov, %qde);
# read and parse paf file to stat qurey sequences
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @f = split /\t/, $_;
	$qaln{$f[0]} += 1;
	$_ =~ /d[ev]:f:([01]\.\d+)/;
	$qde{$f[0]} += $1;
	$qcov{$f[0]} = "N" x $f[1] if not $qcov{$f[0]};
	my $start = $f[2];
	my $len = $f[3] - $f[2];
	substr($qcov{$f[0]}, $start, $len, "X" x $len);
}
close IN;
# output alignment coverage and average sequence divergence of each qurey sequence
print "Qurey\tLength\tCoverage\tDivergence\n";
foreach my $id (sort keys %qaln) {
	my $aln = 0;
	while ($qcov{$id} =~ /X/g) {
		$aln += 1;
	}
	my $len = length($qcov{$id});
	my $de = $qde{$id} / $qaln{$id};
	printf "%s\t%d\t%.4f\t%.4f\n", $id, $len, $aln / $len, $de;
}
