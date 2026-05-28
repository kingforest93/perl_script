#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl exonerate2gff.pl pep.exonerate > pep.exonerate.gff\n";

# read pep.exonerate and output gff
my ($mrna, $gene, $cds, $intron);
my %num;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @t = split /\t/, $_;
	next until $t[1] =~ /exonerate/;
	if ($t[2] eq "gene") {
		$t[8] =~ /\ssequence\s(\S+)\s;/;
		$gene = $1;
		$num{$gene} += 1;
		$mrna = "$gene\.t$num{$gene}";
		$t[8] = "ID=$mrna;Parent=$gene";
		$t[2] = "mRNA";
		print join("\t", @t) . "\n";
	} elsif ($t[2] eq "cds") {
		$cds += 1;
		$t[8] = "ID=$mrna\.cds$cds;Parent=$mrna";
		$t[2] = "CDS";
		print join("\t", @t) . "\n";
	} elsif ($t[2] eq "intron") {
		$intron += 1;
		$t[8] = "ID=$mrna\.intron$intron;Parent=$mrna";
		$t[2] = "Intron";
		print join("\t", @t) . "\n";
	} elsif ($t[2] eq "similarity") {
		$cds = 0;
		$intron = 0;
	}
}
close IN;

