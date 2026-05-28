#!/bin/perl
use strict;

defined $ARGV[1] or die "Usage: perl falen2bed.pl fasta.len window_size > fasta.len.bed\n";

# read fasta.len
my %lens;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my ($id, $len) = split /\t/, $_;
	$lens{$id} = $len;
}
close IN;

# output window-sized bed
my $win = $ARGV[1];
foreach my $id (sort keys %lens) {
	if ($lens{$id} <= $win) {
		print "$id\t0\t$lens{$id}\n";
	} else {
		my $len = $lens{$id};
		my ($start, $end) = (0, 0);
		while ($len >= $win) {
			$end = $start + $win;
			print "$id\t$start\t$end\n";
			$start = $end;
			$len -= $win;
		}
		$end = $start + $len;
		print "$id\t$start\t$end\n";
	}
}
