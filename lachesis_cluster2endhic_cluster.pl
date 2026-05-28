#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read lachesis_clusters.by_name.txt and output in endhic.cluster format.

	Author: Sen Wang, wangsen1993@163.com, 2021/9/14.

	Usage: perl lachesis_cluster2endhic_cluster.pl contigs.len lachesis_clusters.by_name.txt > lachesis_clusters.by_name.txt.cluster
	\n";
}

# read contigs.len
my %ctg_len;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my ($c, $l) = split (/\t/, $_);
	$ctg_len{$c} = $l;
}
close IN;

# read clusters.by_name.txt and output
my %clu2ctg;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @ctgs = split (/\t/, $_);
	my $l = 0;
	my @clu;
	foreach my $ctg (@ctgs) {
		$l += $ctg_len{$ctg};
		push @clu, "$ctg\+";
	}
	@{$clu2ctg{$l}} = @clu;
}
close IN;

#output cluster
print "#Cluster_id\tcontig_count\tcluster_length\trobustness[1]\tcontigs_order_orientation\n";
my $rank = 0;
foreach my $len (sort {$b <=> $a} keys %clu2ctg) {
	$rank += 1;
	my $id = "Cluster_$rank";
	my $count = @{$clu2ctg{$len}};
	my $robust = 1;
	my $cluster = join (";", @{$clu2ctg{$len}});
	print "$id\t$count\t$len\t$robust\t$cluster\n";
}
