#!/usr/bin/perl
use strict;

#parse input
defined $ARGV[0] or die "Usage: perl blastm6_filter.pl Artemisia_annua.pep.m6.best 50 80\n";

#read Artemisia_annua.pep.m6.best
my $file = shift @ARGV;
my $identity = shift @ARGV;
my $coverage = shift @ARGV;
open IN, "<$file" or die "Cannot open $file!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	my $query_cov = ($t[9] - $t[8] + 1) / $t[7] * 100;
	my $target_cov = ($t[12] - $t[11] + 1) / $t[10] * 100;
	if ($t[2] < $identity) {
		next;
	} elsif ($query_cov < $coverage and $target_cov < $coverage) {
		next;
	} else {
		print "$_\n";
	}
}
close IN;
