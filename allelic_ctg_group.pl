#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "
	Description: read whole-contig HiC contact density of within and between contigs, and identify the allelic contig groups (from homolog chromosomes).

	Author: Sen Wang, wangsen1993@163.com, 2022/9/28.

	Usage: perl allelic_ctg_group.pl Ht.all_nucleus_ctg.fa.len.1Mb.contact.density 0.9 > Ht.all_nucleus_ctg.fa.len.1Mb.contact.density.allelic.group.cutoff0.9
\n";

# read intra- and inter-contig HiC contact density
my (%ctg_bins, %inter_dens, %intra_dens);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	next if /^#/;
	my @t = split /\t/, $_;
	if ($t[0] eq $t[1]) {
		$intra_dens{$t[0]} = $t[6];
		$ctg_bins{$t[0]} = $t[2];
	} else {
		my $dens = $t[6];
		$dens = $t[5] if $t[5] > $t[6];
		$inter_dens{$t[0]}{$t[1]} = $dens;
	}
}
close IN;

# output allelic-contig groups
my $ratio = $ARGV[1];
my @ctgs = sort {$ctg_bins{$b} <=> $ctg_bins{$a}} keys %ctg_bins;
while (@ctgs) {
	my $ctg1 = shift @ctgs;
	#my @group = ("${ctg1}_${intra_dens{$ctg1}}");
	my @group = ($ctg1);
	delete $ctg_bins{$ctg1};
	foreach my $ctg2 (@ctgs) {
		my $inter = $inter_dens{$ctg1}{$ctg2};
		$inter = $inter_dens{$ctg2}{$ctg1} if $inter_dens{$ctg2}{$ctg1} > $inter_dens{$ctg1}{$ctg2};
		my $intra = $intra_dens{$ctg1};
		$intra = $intra_dens{$ctg2} if $intra_dens{$ctg2} < $intra_dens{$ctg1};
		if ($inter >= $ratio * $intra) {
			#push @group, "${ctg2}_${inter}_${intra}";
			push @group, $ctg2;
			delete $ctg_bins{$ctg2};
		}
	}
	print join("\t", @group) . "\n";
	@ctgs = sort {$ctg_bins{$b} <=> $ctg_bins{$a}} keys %ctg_bins;
}
