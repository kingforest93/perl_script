#!/usr/bin/perl
use strict;
defined $ARGV[1] or die "Usage: perl cov2depth.pl PB.base.cov windowsize\n";
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
my $ctg;
my $w = $ARGV[1];
my $d = 0;
my $i = 1;
my $len = 0;
my $start = 0;
my $end = 0;
while (<IN>) {
	chomp;
	if (/^>(\S+)\s+(\d+)/) {
		$ctg = $1;
		$len = $2;
		$start = 0;
	} else {
		my @t = split /\t/, $_;
		$end = ($i * $w);
		if ($t[1] <= $end and $t[1] < $len) {
			$d += ($t[2] * ($t[1] - $t[0] + 1));
		} elsif ($t[1] > $end and $t[1] < $len) {
			$d = sprintf "%.1f", ($d / $w);
			print "$ctg\t$start\t$end\t$d\n";
			$d = ($t[2] * ($t[1] - $t[0] + 1));
			$i += 1;
			$start = $end;
		} else {
			$d += ($t[2] * ($t[1] - $t[0] + 1));
			$d = sprintf "%.1f", ($d / ($len - $end + $w));
			print "$ctg\t$start\t$len\t$d\n";
			$d = 0;
			$i = 1;
		}
	}
}
close IN;
