#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "perl nwk_filter.pl Htub.Chr06.H1-6.single.copy.cds.fasttrees\n";

open IN, "<$ARGV[0]" or die "$!\n";
my $line;
while (<IN>) {
	chomp;
	$line += 1;
	my $n;
	while (/\([\w\.\:]+?,[\w\.\:]+?[,\)]/g) {
		$n += 1;
	}
	print "$line\n" if $n == 3;
}
close IN;
