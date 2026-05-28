#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl fa_paf_rmdup.pl input.fa input.paf 1>output.fa 2>rm.len\n";

# read input.fa
my %seqs;
my $h;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(\w+)/) {
		$h = $1;
	} else {
		$seqs{$h} .= $_;
	}
}
close IN;

# read input.paf and remove redundant fragments
my %aln;
if ($ARGV[1] =~ /\.gz/) {
	open IN, "gzip -dc $ARGV[1] |" or die "Cannot open $ARGV[1]!\n";
} else {
	open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
}
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	#next if $t[12] eq "tp:A:S" or $t[11] == 0; # skip secondary or low-quality alignments
	next if $t[10] <= 10000; # skip alignments shorter than 10000 bp
	next if $t[16] =~ /dv:f:(\d\.\d+)/ and $1 >= 0.05; # skip alignments with divergence higher than 0.05
	#next if $t[0] eq $t[5]; # skip self alignments
	my $qur = "$t[0]_$t[2]_$t[3]";
	my $ref = "$t[5]_$t[7]_$t[8]";
	if ($aln{$qur}) {
		next; # skip redundant alignments
	} else {
		$aln{$ref} = 1;
	}
	$qur = $t[0];
	my $start = $t[2];
	my $len = $t[3] - $t[2];
	substr($seqs{$qur}, $start, $len, "N" x $len);
}
close IN;

# output non-redundant contigs
foreach $h (sort keys %seqs) {
	my $rm = 0;
	print ">$h\n$seqs{$h}\n";
	while ($seqs{$h} =~ /N/g) {$rm += 1};
	print STDERR "$h\t$rm\n";
}
