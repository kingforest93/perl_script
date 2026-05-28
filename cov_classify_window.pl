#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[1] or die "Usage: perl cov_classify_window.pl PB.base.cov.50kb.dp haplo_cov(14) > PB.base.cov.50kb.dp.classify.stat\n";

# determine cov of each window type
my $c = $ARGV[1];
my ($r, $p1, $p2, $p3, $p4, $p5, $p6) = (3, $c * 1.5, $c * 2.5, $c * 3.5, $c * 4.5, $c * 5.5, $c * 6.5);

# read PB.base.cov.50kb.dp and classify
my ($total, $repeat, $haplotig, $diplotig, $triplotig, $tetraplotig, $pentaplotig, $hexaplotig);
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	my $len = $t[2] - $t[1];
	$total += $len;
	if ($t[3] < $r) {
		$repeat += $len;
	} elsif ($t[3] < $p1) {
		$haplotig += $len;
	} elsif ($t[3] < $p2) {
		$diplotig += $len;
	} elsif ($t[3] < $p3) {
		$triplotig += $len;
	} elsif ($t[3] < $p4) {
		$tetraplotig += $len;
	} elsif ($t[3] < $p5) {
		$pentaplotig += $len;
	} elsif ($t[3] < $p6) {
		$hexaplotig += $len;
	} else {
		$repeat += $len;
	}
}
close IN;

# output classify results
printf "%12s\t%12s\t%10s\n", "Type", "Length(bp)", "Percent(%)";
printf "%12s\t%12d\t%3.2f\n", "Total", $total, $total / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Repeat", $repeat, $repeat / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Haplotig", $haplotig, $haplotig / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Diplotig", $diplotig, $diplotig / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Triplotig", $triplotig, $triplotig / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Tetraplotig", $tetraplotig, $tetraplotig / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Pentaplotig", $pentaplotig, $pentaplotig / $total * 100;
printf "%12s\t%12d\t%3.2f\n", "Hexaplotig", $hexaplotig, $hexaplotig / $total * 100;
