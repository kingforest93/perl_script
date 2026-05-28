#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "Usage: perl cluster2group.pl clusters.by_name.txt counts_RE.txt\n";
my %group;
my $c = 0;
# read lachesis cluster results
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @t = split /\s/, $_;
	$c += 1;
	@{$group{$c}} = @t;
}
close IN;
# read length and REsite of each contig
my (%resites, %lens);
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @t = split /\s/, $_;
	$resites{$t[0]} = $t[1];
	$lens{$t[0]} = $t[2];
}
close IN;
# output cluster in allhic format
my $out = $ARGV[1];
$out =~ s/counts_GATC/clusters/;
open OUT, ">$out" or die "Cannot create or write to $out\n";
print OUT "#Group\tnContigs\tContigs\n";
foreach my $i (sort {$a <=> $b} keys %group) {
	my $l1 = $c . "g" . $i;
	my $l2 = @{$group{$i}};
	my $l3 = join(" ", @{$group{$i}});
	print OUT "$l1\t$l2\t$l3\n";
}
close OUT;
foreach my $i (sort {$a <=> $b} keys %group) {
	my $g = $c . "g" . $i;
	$out = $ARGV[1];
	$out =~ s/\.txt/\.$g\.txt/;
	open OUT, ">$out" or die "Cannot create or write to $out\n";
	print OUT "#Contig\tRECounts\tLength\n";
		foreach my $j (@{$group{$i}}) {
			print OUT "$j\t$resites{$j}\t$lens{$j}\n";
		}
	close OUT;
}
