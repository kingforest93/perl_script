#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read augustus_prediction.gff and remove the incomplete genes (transcripts) lacking start or stop codon.

	Author: Sen Wang, wangsen1993@163.com, 2021/11/22.

	Usage: perl augustus_gff_filter.pl genome.augustus.gff 1>genome.augustus.complete.gff 2>genome.augustus.codon.stat
	\n";
}

# read genome.augustus.gff
my (%gene, %gene2start, %gene2stop);
my $id;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @t = split(/\t/, $_);
	if ($t[2] eq "gene") {
		$t[8] =~ /ID=([\w\.]+)/;
		$id = $1;
		$gene{$id} = 1;
	} elsif ($t[2] eq "start_codon") {
		$gene2start{$id} += 1;
	} elsif ($t[2] eq "stop_codon") {
		$gene2stop{$id} += 1;
	} else {
		next;
	}
}
close IN;

# output the number of start and stop codon for each gene
print STDERR "#Gene_id\tNum_start_codon\tNum_stop_codon\n";
foreach $id (sort keys %gene) {
	$gene2start{$id} = 0 if not $gene2start{$id};
	$gene2stop{$id} = 0 if not $gene2stop{$id};
	print STDERR "$id\t$gene2start{$id}\t$gene2stop{$id}\n";
}

# output only complete genes with both start and stop codon
my $flag = 0;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @t = split(/\t/, $_);
	if ($t[2] eq "gene") {
		$t[8] =~ /ID=([\w\.]+)/;
		$id = $1;
		if ($gene2start{$id} == 1 and $gene2stop{$id} == 1) {
			$flag = 1;
			print STDOUT $_;
		} else {
			$flag = 0;
			next;
		}
	} else {
		if ($flag == 1) {
			print STDOUT $_;
		} else {
			next;
		}
	}
}
close IN;
