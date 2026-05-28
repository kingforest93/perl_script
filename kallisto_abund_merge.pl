#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl kallisto_abund_merge.pl item(est_counts/tpm) file1.tsv file2.tsv ... \n";

# read profile
my %exp;
my @sample;
my $item = shift @ARGV;
foreach my $file (@ARGV) {
	open IN, "<$file" or die "Cannot open $file!\n";
	$file =~ s/_out\/abundance.tsv//;
	push @sample, $file;
	while (<IN>) {
		chomp;
		my @t = split /\t/, $_;
		next if $t[0] eq "target_id";
		if ($item eq "est_counts") {
			push @{$exp{$t[0]}}, $t[3]; 
		} elsif ($item eq "tpm") {
			push @{$exp{$t[0]}}, $t[4];
		}
	}
	close IN;
}

# output profile
print "Transcript\t" . join("\t", @sample) . "\n";
foreach my $t (sort keys %exp) {
	print "$t\t" . join("\t", @{$exp{$t}}) . "\n";
}
