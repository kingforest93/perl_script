#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl linksort.pl Hthic_frag_scaf_ctg.sorted.validPairs.wholelinks > Hthic_frag_scaf_ctg.sorted.validPairs.wholelinks.sorted";

# read links and sort
my $ctg;
my %link;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	next if not $t[2] =~ /\d+/;
	if (not $ctg) {
		$ctg = $t[0];
		$link{$t[1]} = $t[2];
	} elsif ($ctg ne $t[0]) {
		foreach my $c (sort {$link{$b} <=> $link{$a}} keys %link) {
			print "$ctg\t$c\t$link{$c}\n";
		}
		%link = ();
		$ctg = $t[0];
		$link{$t[1]} = $t[2];
	} else {
		$link{$t[1]} = $t[2];
	}
}
close IN;
