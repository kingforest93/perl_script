#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "
	Description: read alignment PAF file produced by minimap2 and output the base depth of reference sequences.
	
	Author: Sen Wang, wangsen1993@163.com, 2021/3/4.

	Usage: perl paf_ref_depth.pl input.paf > output.depth
	\n";
my %rdepths;
# read and parse paf file
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @f = split /\t/, $_;
	if (not $rdepths{$f[5]}) {
		my @pos;
		foreach my $p (0 .. ($f[6] - 1)) {
			$pos[$p] = 0;
		}
		$rdepths{$f[5]} = [@pos];
	}
	foreach my $p ($f[7] .. $f[8]) {
		$rdepths{$f[5]}[$p] += 1;
	}
}
close IN;
# output reference depth
print "Ref\tStart\tEnd\tDepth\n";
my ($cur, $s, $e);
foreach my $id (sort keys %rdepths) {
	$s = 1;
	my @dep = @{$rdepths{$id}};
	my $cur = $dep[0];
	foreach my $p (1 .. (@dep - 1)) {
		if ($dep[$p] == $cur) {
			$e = $p + 1;
			next;
		} else {
			$e -= 1;
			print "$id\t$s\t$e\t$cur\n";
			$s = $e + 1;
			$cur = $dep[$p];
		}
	}
}

