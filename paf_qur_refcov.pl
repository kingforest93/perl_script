#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "
	Description: read alignment PAF file produced by minimap2 and output the accumulated alignment coverage of each reference to each qurey.
	
	Author: Sen Wang, wangsen1993@163.com, 2022/10/10.

	Usage: perl paf_qur_refcov.pl input.paf min_mapq(30) > output.stat
\n";

# read and parse paf file to get sequence and alignment length
my $mapq = $ARGV[1];
$mapq = 30 if not $mapq;
my %qcov;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @f = split /\t/, $_;
	next if $f[11] < $mapq;
	my $pair = "$f[0]-$f[5]";
	$qcov{$pair} = "N" x $f[1] if not $qcov{$pair};
	my $start = $f[2];
	my $len = $f[3] - $f[2];
	substr($qcov{$pair}, $start, $len, "X" x $len);
}
close IN;

# output alignment coverage of each qurey-reference pair
print "Qurey\tLength\tCoverage\tReference\n";
foreach my $pair (sort keys %qcov) {
	my $qaln = 0;
	while ($qcov{$pair} =~ /X/g) {
		$qaln += 1;
	}
	my $qlen = length($qcov{$pair});
	my ($q, $r) = split(/-/, $pair);
	printf "%s\t%d\t%.4f\t%s\n", $q, $qlen, $qaln / $qlen, $r;
}
