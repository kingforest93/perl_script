#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "
	Description: convert multiple-sequence alignment in fasta format produced by muscle to the phylip format used by bpp
	
	Author: Sen Wang, wangsen1993@163.com, 2022/6/23
	
	Usage: perl msafa2phylip.pl multi_align.dir > combine.muscle.phylip
\n";

# read multiple MSAs and convert into one phylip file
foreach my $file ( glob("$ARGV[0]/*.muscle") ) {
	# read MSA in fasta format
	my $num = 0;
	my %seqs;
	my $id;
	open IN, "<$file" or die "Cannot open $file!\n";
	while (<IN>) {
		chomp;
		if (/^>(\w+?)\.(\S+)/) {
			$id = "$2\^$1";
			$num += 1;
		} else {
			$seqs{$id} .= $_;
		}
	}
	close IN;
	my $len = length($seqs{$id});
	# output MSA in phylip format
	print "$num  $len\n\n";
	foreach $id (sort keys %seqs) {
		printf "%-50s  %s\n", $id, $seqs{$id};
	}
	print "\n";
}
