#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl agp_add_ctg.pl Ht_all_ctg_nucleus.fa.len Ht_chr_scaf_ctg.agp prefix(replace_scaffold) > Ht_chr_scaf_ctg.added.agp\n";

# read Ht_all_ctg_nucleus.fa.len
my %lens;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$lens{$t[0]} = $t[1];
}
close IN;

# read Ht_chr_scaf_ctg.agp
my %group;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$group{$t[5]} = 1;
	print "$_\n";
}
close IN;

# add ungrouped contigs to agp
my $prefix = $ARGV[2];
my $num = 0;
foreach my $id (sort {$a <=> $b} keys %lens) {
	next if $group{$id} == 1;
	$num += 1;
	my $scaf = "${prefix}_ctg_${num}";
	my $end = $lens{$id};
	print "$scaf\t1\t$end\t1\tW\t$id\t1\t$end\t\+\n";
}
