#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl cafe_OG_select.pl Gamma_branch_probabilities.tab Gamma_change.tab 6 1>expanded.OGs 2>contracted.OGs\n";

# read Gamma_branch_probabilities.tab
my $column = $ARGV[2] - 1;
my %pvalue;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^#FamilyID/;
	my @t = split /\t/, $_;
	$pvalue{$t[0]} = 1 if $t[$column] < 0.05;
}
close IN;

# read Gamma_change.tab and output
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^FamilyID/;
	my @t = split /\t/, $_;
	if ($pvalue{$t[0]} == 1 and $t[$column] =~ /\+[1-9]/) {
		print STDOUT "$t[0]\n";
	} elsif ($pvalue{$t[0]} == 1 and $t[$column] =~ /\-[1-9]/) {
		print STDERR "$t[0]\n";
	} else {
		next;
	}
}
close IN;
