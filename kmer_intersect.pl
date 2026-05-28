#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "Usage: perl kmer_intersect.pl species_A_kmer.freq.gz species_B_kmer.freq.gz\n";
my (%kmerA, %kmerB, %kmer_AB);
my ($num_A, $num_B, $num_AB);
#kmer species of the first species
open IN, "gunzip -c $ARGV[0] |" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$kmerA{$t[0]} = 1;
}
close IN;
$num_A = keys %kmerA;
#kmer species of the second species
open IN, "gunzip -c $ARGV[1] |" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$kmerB{$t[0]} = 1;
	if ($kmerA{$t[0]} == 1) {
		$kmer_AB{$t[0]} = 1;
	}
}
close IN;
$num_B = keys %kmerB;
$num_AB = keys %kmer_AB;
printf "%s kmer species:\t%d\n%s kmer species:\t%d\nintersect kmer species:\t%d\n", $ARGV[0], $num_A, $ARGV[1], $num_B, $num_AB;

