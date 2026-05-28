#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "
	Description: convert augustus hints file to gff3 format.

	Author: Sen Wang, wangsen1993@163.com, 2023/2/3.

	Usage: perl hints2gff.pl TH_leaf2.flnc.cDNA.fa.clean.psl.filtered.hints > TH_leaf2.flnc.cDNA.fa.clean.psl.filtered.hints.gff
\n";

# read, group and store mRNA features
my (%mrna, %new);
my ($parent, $id);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split (/\t/, $_);
	$t[8] =~ /grp=([^;]+);/;
	$parent = $1;
	$id = "$parent\.t1";
	$new{$id}[0] = $t[0] if not $new{$id}[0];
	$new{$id}[1] = $t[1] if not $new{$id}[1];
	$new{$id}[2] = "mRNA" if not $new{$id}[2];
	$new{$id}[3] = $t[3] if not $new{$id}[3];
	$new{$id}[3] = $t[3] if $t[3] < $new{$id}[3];
	$new{$id}[4] = $t[4] if not $new{$id}[4];
	$new{$id}[4] = $t[4] if $t[4] > $new{$id}[3];
	$new{$id}[5] = 0 if not defined $new{$id}[5];
	$new{$id}[6] = "\." if not defined $new{$id}[6];
	$new{$id}[7] = "\." if not defined $new{$id}[7];
	$new{$id}[8] = "ID=$id;Parent=$parent" if not $new{$id}[8];
	$t[8] = "Parent=$id";
	$t[2] = "exon" if $t[2] eq "ep";
	$t[2] = "CDS" if $t[2] eq "CDSpart";
	$mrna{$id}{$t[3]} = join ("\t", @t);
}
close IN;

# output mRNA features in GFF3
foreach $id (sort keys %new) {
	print join("\t", @{$new{$id}}) . "\n";
	my ($exon, $intron, $cds) = (0, 0);
	foreach my $start (sort {$a <=> $b} keys %{$mrna{$id}}) {
		my @t = split ("\t", $mrna{$id}{$start});
		if ($t[2] eq "exon") {
			$exon += 1;
			$t[8] = "ID=$id\.exon$exon;$t[8]";
			print join("\t", @t) . "\n";
		} elsif ($t[2] eq "CDS") {
			$cds += 1;
			$t[8] = "ID=$id\.cds$cds;$t[8]";
			print join("\t", @t) . "\n";
		} elsif ($t[2] eq "intron") {
			$intron += 1;
			$t[8] = "ID=$id\.intron$intron;$t[8]";
			print join("\t", @t) . "\n";
		}
	}
	($exon, $intron, $cds) = (0, 0, 0);
}
