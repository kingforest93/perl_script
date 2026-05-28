#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "
	Description: read FASTA file and replace the headers by the corresponding headers given in an file.

	Author: Sen Wang, wangsen1993@163.com, 2023/10/05.

	Usage: perl header_replace.pl header.list original.fasta > replaced.fasta
\n";

# read header.list
my %list;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my ($short, $long) = split /\t/, $_;
	$list{$short} = $long;
}
close IN;

# read fasta and replace header
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	if (/^>(HtChr[0-1][0-9]\.H[1-6])/) {
		my $old = $1;
		my $new = $list{$old};
		if ($new) {
			$_ =~ s/$old/$new/;
			print "$_";
		} else {
			print "$_";
		}
	} else {
		print $_;
	}
}
close IN;
