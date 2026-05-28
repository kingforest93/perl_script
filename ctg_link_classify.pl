#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl ctg_link_classify.pl Ht_group_scaf.fa.len Hthic_frag_scaf_ctg.sorted.validPairs.wholelinks minimum_link(default 1) second_to_first_ratio(default 0.5) > Hthic_frag_scaf_ctg.sorted.validPairs.wholelinks.classified\n";

# read and record unscaffolded fragment ids
my %frag;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$frag{$t[0]} = 1;
}
close IN;

# read sorted links and classify
my $min = $ARGV[1];
my $ratio = $ARGV[2];
$min = 1 if not $min;
$ratio = 0.5 if not $ratio;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
my $ctg;
my %link;
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	next if not $frag{$t[0]};
	next if $t[2] < $min;
	if (not $ctg) {
		$ctg = $t[0];
		$link{$1} += $t[2] if $t[1] =~ /(Ha\d+?)_/;
	} elsif ($ctg ne $t[0]) {
		my @k = sort {$link{$b} <=> $link{$a}} keys %link;
		my @v = sort {$b <=> $a} values %link;
		if (not $v[0]) {
			print "$ctg\tUnclassified\n";
		} elsif (not $v[1]) {
			print "$ctg\t$k[0]\n";
		} elsif ($v[0] / $v[1] > $ratio) {
			print "$ctg\t$k[0]\n";
		} else {
			print "$ctg\tUnclassified\n";
		}
		%link = ();
		$ctg = $t[0];
		$link{$1} += $t[2] if $t[1] =~ /(Ha\d+?)_/;
	} else {
		$link{$1} += $t[2] if $t[1] =~ /(Ha\d+?)_/;
	}
}
close IN;
