#!/usr/bin/perl
use strict;
use Getopt::Long;
# parse input options
my ($rev, $help);
GetOptions(
	'reverse|r!' => \$rev,
	'help|h!' => \$help
);
if (not $ARGV[0] or $help) {
	die "
	Description: read contig sequences and filter them by the given contig id list, output the sequences of contigs in the list (default) or not in the list (-r).

	Author: Sen Wang, wangsen1993@163.com, 2021/7/12.

	Usage: perl contig_select.pl [-r] contig_id.list contigs.fasta > selected.contigs.fasta
	\n";
}
my %sel;
# read contig ids
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @t = split /\s+/, $_;
	$sel{$t[0]} = 1;
}
close IN;
# read and select contigs
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
my $flag;
while (<IN>) {
	if ($rev) {
		if (/^>(\S+)/ and $sel{$1} != 1) {
			$flag = 1;
			print $_;
			#print STDERR $_;
		} elsif (/^>(\S+)/ and $sel{$1} == 1) {
			$flag = 0;
		} else {
			print $_ if $flag == 1;
		}
	} else {
		if (/^>(\S+)/ and $sel{$1} == 1) {
			$flag = 1;
			print $_;
			#print STDERR $_;
		} elsif (/^>(\S+)/ and $sel{$1} != 1) {
			$flag = 0;
		} else {
			print $_ if $flag == 1;
		}
	}
}
close IN;
