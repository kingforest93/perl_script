#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl busco_table_gene.pl Ht_hifiasm.all_ctg.l0.fa Ht_hifiasm.all_ctg.l0_full_table.tsv > Ht_hifiasm.all_ctg.l0_full_table.gene.fa\n";

# read Ht_hifiasm.all_ctg.l0.fa
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

# read Ht_hifiasm.all_ctg.l0_full_table.tsv and output genes
my $rank = 0;
$id = "";
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @t = split /\t/, $_;
	$id = $t[0] if not $id;
	if ($t[0] eq $id) {
		$rank += 1;
		my $header = "$id\.$rank";
		my $seq = substr($seqs{$t[2]}, $t[3], $t[4] - $t[3] + 1);
		if ($t[5] eq "-") {
			$seq = reverse $seq;
			$seq =~ tr/ATCG/TAGC/;
		}
		print ">$header\n$seq\n";
	} else {
		$rank = 1;
		$id = $t[0];
		my $header = "$id\.$rank";
		my $seq = substr($seqs{$t[2]}, $t[3], $t[4] - $t[3] + 1);
		if ($t[5] eq "-") {
			$seq = reverse $seq;
			$seq =~ tr/ATCG/TAGC/;
		}
		print ">$header\n$seq\n";
	}
}
close IN;
