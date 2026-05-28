#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[1] or die "Usage: perl cov_classify_ctg.pl PB.base.cov.50kb.dp haplo_cov(14) ratio_min(0.8) > PB.base.cov.50kb.dp.classify.table\n";

# determine cov of each window type
my $c = $ARGV[1];
my ($r, $p1, $p2, $p3, $p4, $p5, $p6) = (3, $c * 1.5, $c * 2.5, $c * 3.5, $c * 4.5, $c * 5.5, $c * 6.5);
my $min = $ARGV[2];
$min = 0.8 if not $min;

# read PB.base.cov.50kb.dp and classify each window
my (%total, %repeat, %haplotig, %diplotig, %triplotig, %tetraplotig, %pentaplotig, %hexaplotig);
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	my $len = $t[2] - $t[1];
	$total{$t[0]} += $len;
	if ($t[3] < $r) {
		$repeat{$t[0]} += $len;
	} elsif ($t[3] < $p1) {
		$haplotig{$t[0]} += $len;
	} elsif ($t[3] < $p2) {
		$diplotig{$t[0]} += $len;
	} elsif ($t[3] < $p3) {
		$triplotig{$t[0]} += $len;
	} elsif ($t[3] < $p4) {
		$tetraplotig{$t[0]} += $len;
	} elsif ($t[3] < $p5) {
		$pentaplotig{$t[0]} += $len;
	} elsif ($t[3] < $p6) {
		$hexaplotig{$t[0]} += $len;
	} else {
		$repeat{$t[0]} += $len;
	}
}
close IN;

# classify each contig by the major type of window and output
foreach my $ctg (keys %total) {
	if ($repeat{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\trepeat\n";
	} elsif ($haplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\thaplotig\n";
	} elsif ($diplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\tdiplotig\n";
	} elsif ($triplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\ttriplotig\n";
	} elsif ($tetraplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\ttetraplotig\n";
	} elsif ($pentaplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\tpentaplotig\n";
	} elsif ($hexaplotig{$ctg} >= $total{$ctg} * $min) {
		print "$ctg\t$total{$ctg}\thexaplotig\n";
	} else {
		my @tem;
		push @tem, "repeat:$repeat{$ctg}" if $repeat{$ctg} > 0;
		push @tem, "haplotig:$haplotig{$ctg}" if $haplotig{$ctg} > 0;
		push @tem, "diplotig:$diplotig{$ctg}" if $diplotig{$ctg} > 0;
		push @tem, "triplotig:$triplotig{$ctg}" if $triplotig{$ctg} > 0;
		push @tem, "tetraplotig:$tetraplotig{$ctg}" if $tetraplotig{$ctg} > 0;
		push @tem, "pentaplotig:$pentaplotig{$ctg}" if $pentaplotig{$ctg} > 0;
		push @tem, "hexaplotig:$hexaplotig{$ctg}" if $hexaplotig{$ctg} > 0;
		print "$ctg\t$total{$ctg}\t" . join("\t", @tem) . "\n";
	}
}
