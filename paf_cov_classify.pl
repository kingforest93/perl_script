#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "
	Description: read the accumulated alignment coverage of each qurey and identify the potential pseudochromosome which it comes from.
	
	Author: Sen Wang, wangsen1993@163.com, 2022/10/12.

	Usage: perl paf_cov_classify.pl input.qur_refcov second_to_first_ratio(0.9) > output.qur_refcov.group
\n";

# read the alignment coverage of each query-reference pair
my $cutoff = $ARGV[1];
$cutoff = 0.9 if not $cutoff;
my %cov;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
readline IN;
while (<IN>) {
	chomp;
	my @f = split /\t/, $_;
	$cov{$f[0]}{$f[3]} = $f[2];
}
close IN;

# output the qurey-reference pairs meeting second-to-first ratio of alignment coverage
print "Qurey\tReference\tCoverage\n";
foreach my $qur (sort keys %cov) {
	my @k = sort {$cov{$qur}{$b} <=> $cov{$qur}{$a}} keys %{$cov{$qur}};
	my @v = sort {$b <=> $a} values %{$cov{$qur}};
	if (@v == 1) {
		print "$qur\t$k[0]\t$v[0]\n";
	} elsif ($v[1] <= $cutoff * $v[0]) {
		print "$qur\t$k[0]\t$v[0]\n";
	} else {
		print "$qur\t$k[0]\t$v[0]";
		foreach my $i (1 .. @v) {
			if ($v[$i] >= $cutoff * $v[0]) {
				print "\t$k[$i]\t$v[$i]";
			}
		}
		print "\n";
	}
}
