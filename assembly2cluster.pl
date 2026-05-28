#!/usr/bin/perl
use strict;

#parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read 3d-dna.assembly and transform into endhic.cluster.

	Author: Sen Wang, wangsen1993@163.com, 2021/9/14.

	Usage: perl assembly2cluster.pl 3d-dna_draft.FINAL.assembly > 3d-dna_draft.FINAL.assembly.cluster
	\n";
}

# read 3d-dna.assembly
my (%ctg_id, %ctg_len, %clu2ctg);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>/) {
		my ($ctg, $id, $len) = split(/\s/, $_);
		$ctg =~ s/>//;
		$ctg_id{$id} = $ctg;
		$ctg_len{$id} = $len;
	} else {
		my @ids = split (/\s/, $_);
		my $len;
		my @ctgs;
		foreach my $id (@ids) {
			if ($id =~ /^\d/) {
				next if $ctg_id{$id} =~ /hic_gap/;
				$len += $ctg_len{$id};
				push @ctgs, "$ctg_id{$id}\+"; 
			} else {
				$id =~ s/-//;
				$len += $ctg_len{$id};
				push @ctgs, "$ctg_id{$id}\-";
			}
		}
		@{$clu2ctg{$len}} = @ctgs;
	}
}
close IN;

# output in Cluster format
print "#Cluster_id\tcontig_count\tcluster_length\trobustness[1]\tcontigs_order_orientation\n";
my $rank = 0;
foreach my $len (sort {$b <=> $a} keys %clu2ctg) {
	$rank += 1;
	my $cluster = "Scaffold_$rank";
	my $num = @{$clu2ctg{$len}};
	my $robust = 1;
	my $ctgs = join (";", @{$clu2ctg{$len}});
	print "$cluster\t$num\t$len\t$robust\t$ctgs\n";
}
