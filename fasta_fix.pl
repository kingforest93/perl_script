#!/usr/bin/perl
use strict;

#parse input
defined $ARGV[0] or die "Usage: perl fasta_fix.pl Glebionis_coronaria_scaffolds_v1.fa sequence_trim.region > Glebionis_coronaria.fsa\n";

# read Glebionis_coronaria_scaffolds_v1.fa
my %seqs;
my $head;
my @headers;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$head = $1;
		push @headers, $head;
	} else {
		$seqs{$head} .= $_;
	}
}
close IN;

# read sequence_trim.region and trim regions by changing ATCGs to Ns
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t1 = split /\s+/, $_;
	my @t2 = split /,|\.\./, $t1[2];
	if ($seqs{$t1[0]}) {
		while (@t2) {
			my $start = shift @t2;
			my $end = shift @t2;
			substr $seqs{$t1[0]}, $start - 1, $end - $start + 1, "N" x ($end - $start + 1);
		}
	}
}
close IN;

# output trimmed sequences
foreach $head (@headers) {
	print ">$head\n";
	my $seq = $seqs{$head};
    for (my $i = 0; $i < length($seq); $i += 60) {
        my $sub = substr($seq, $i, 60);
        print "$sub\n";
    }
}
