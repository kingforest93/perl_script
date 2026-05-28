#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[1] or die "Usage: perl contig_substr.pl Ht_ctg.fa Ht_ungroup_ctg.ids.mis > Ht_ungroup_ctg.ids.mis.fa\n";

# read sequences
my %seqs;
my $h;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$h = $1;
	} else {
		$seqs{$h} .= $_;
	}
}
close IN;

# read fragment bed
my %frag;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	push @{$frag{$t[0]}}, "$t[1]_$t[2]";
}
close IN;

# output fragments
foreach $h (sort keys %frag) {
	my $rank = 0;
	foreach my $span (sort @{$frag{$h}}) {
		my @t = split /_/, $span;
		$rank += 1;
		my $header = "$h\_$rank";
		my $start = $t[0] - 1;
		my $len = $t[1] - $t[0] + 1;
		my $seq = substr($seqs{$h}, $start, $len);
		print ">$header\n$seq\n";
	}
}
