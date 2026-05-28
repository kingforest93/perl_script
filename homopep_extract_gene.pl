#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl homopep_extract_gene.pl Ht_all_l0_nucleus.fa Helianthus_annuus.gff.long.pep.gff gene_number_per_protein(6)\n";

# read Ht_all_l0_nucleus.fa
my %seqs;
my $header;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$header = $1;
	} else {
		$seqs{$header} .= $_;
	}
}
close IN;

# read Helianthus_annuus.gff.long.pep.gff
my $copy = $ARGV[2];
$copy = 6 if not $copy;
my %genes;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @t = split /\t/, $_;
	if ($t[2] eq "mRNA") {
		$t[8] =~ /Target=(\S+)/;
		my $id = $1;
		$header = $t[0];
		my $start = $t[3] - 1;
		my $len = $t[4] - $t[3] + 1;
		push @{$genes{$id}}, "$header:$start:$len";
	}
}
close IN;

# output desired genes
mkdir "$ARGV[1]\.copy$copy" or die "Cannot create $ARGV[1]\.copy$copy!\n";
chdir "$ARGV[1]\.copy$copy";
foreach my $id (keys %genes) {
	my @lines = @{$genes{$id}};
	if (@lines == $copy) {
		open OUT, ">$id\.fa" or die "Cannot write to $id\.fa!\n";
		foreach my $line (@lines) {
			print OUT ">$line\n";
			my @t = split /:/, $line;
			print OUT substr($seqs{$t[0]}, $t[1], $t[2]) . "\n";
		}
		close OUT;
		print "$id\n";
	}
}
