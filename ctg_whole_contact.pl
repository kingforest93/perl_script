#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "
	Description: read contig list, HiCPro's bed and matrix, and calculate the inter- and intra-contig average contact density, taking the whole contig as basic unit.

	Author: Sen Wang, wangsen1993@163.com, 2022/9/28.

	Usage: perl ctg_whole_contact.pl Ht.all_nucleus_ctg.fa.len.1Mb Hthic_100000_abs.bed Hthic_100000.matrix > Ht.all_nucleus_ctg.fa.len.1Mb.contact.density
\n";

# read contig list
my %ctgs;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$ctgs{$t[0]} = 1;
}
close IN;

# read HiCPro's bed
my (%bin2ctg, %ctg2bin_num);
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	if ($ctgs{$t[0]}) {
		$bin2ctg{$t[3]} = $t[0];
		$ctg2bin_num{$t[0]} += 1;
	}
}
close IN;

# read HiCPro's matrix
my %contact;
open IN, "<$ARGV[2]" or die "Cannot open $ARGV[2]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	if ($bin2ctg{$t[0]} and $bin2ctg{$t[1]}) {
		my $ctg1 = $bin2ctg{$t[0]};
		my $ctg2 = $bin2ctg{$t[1]};
		$contact{"$ctg1-$ctg2"} += $t[2];
	}
}
close IN;

# output HiC contact density (per bin)
print "#Ctg_1\tCtg_2\tBin_num_1\tBin_num_2\tTotal_contact\tContact_density_1\tContact_density_2\n";
foreach (sort keys %contact) {
	my $tot = $contact{$_};
	my ($ctg1, $ctg2) = split /-/, $_;
	my $bin1 = $ctg2bin_num{$ctg1};
	my $bin2 = $ctg2bin_num{$ctg2};
	my $dens1 = $tot / $bin1;
	my $dens2 = $tot / $bin2;
	printf "%s\t%s\t%d\t%d\t%d\t%.2f\t%.2f\n", $ctg1, $ctg2, $bin1, $bin2, $tot, $dens1, $dens2;
}
