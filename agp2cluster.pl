#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read scaffolds.agp and output in endhic.cluster format.

	Author: Sen Wang, wangsen1993@163.com, 2021/9/14.

	Usage: perl agp2cluster.pl groups.agp > groups.agp.cluster
	\n";
}

# read groups.agp
my (%clu_len, %clu2ctg);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split (/\t/, $_);
	next if $f[4] ne "W";
	$clu_len{$f[0]} += $f[7];
	push @{$clu2ctg{$f[0]}}, "$f[5]$f[8]";
}
close IN;

#output cluster
print "#Cluster_id\tcontig_count\tcluster_length\trobustness[1]\tcontigs_order_orientation\n";
foreach my $id (sort {$clu_len{$b} <=> $clu_len{$a}} keys %clu_len) {
	my $count = @{$clu2ctg{$id}};
	my $len = $clu_len{$id};
	my $robust = 1;
	my $cluster = join (";", @{$clu2ctg{$id}});
	print "$id\t$count\t$len\t$robust\t$cluster\n";
}
