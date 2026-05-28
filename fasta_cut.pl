#!/usr/bin/perl
use strict;

# parse input options
defined $ARGV[0] or die "perl fasta_cut.pl contigs.fa fragment_size(50000) > contigs_50kb_frag.fa\n";
my $frag = $ARGV[1];
$frag = 50000 if not $frag;

# read contigs.fa
my %seqs;
my $id;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$id = $1;
	} else {
		$seqs{$id} .= $_;
	}
}
close IN;

# cut into fragments and output
foreach $id (sort keys %seqs) {
	my $seq = $seqs{$id};
	my $len = length($seq);
	if ($len <= 1.5 * $frag) {
		print ">$id\n$seq\n";
	} else {
		my $num = 0;
		my $cur_pos = 0;
		my $cur_seq = "";
		while ($len > 1.5 * $frag) {
			$num += 1;
			$cur_seq = substr($seq, $cur_pos, $frag);
			print ">${id}_$num\n$cur_seq\n";
			$cur_pos += $frag;
			$len -= $frag;
		}
		$num += 1;
		$cur_seq = substr($seq, $cur_pos, );
		print ">${id}_$num\n$cur_seq\n";
	}
}
