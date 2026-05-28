#!/usr/bin/perl
use strict;
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read hcluster.log, cluster.len, and half.cluster.Contact, output the ordered and oriented clusters of N groups.

	Author: Sen Wang, wangsen1993@163.com, 2021/9/2.

	Usage: perl hcluster2cluster.pl z.EndHiC.results.summary.and.analysis.B.cluster.len combine_100000.matrix.half.B.cluster.Contact z.EndHiC.results.summary.and.analysis.B.cluster.distance.hcluster.log N > z.EndHiC.results.summary.and.analysis.B.cluster.distance.hcluster.groupN.cluster
	\n";
}

# read cluster.len
my %clu_len;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my ($c, $l) = split(/\t/, $_);
	$clu_len{$c} = $l;
}
close IN;

# read half.cluster.Contact
my %clu_end;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @f = split(/\t/, $_);
	next if $clu_end{$f[0]}{$f[1]};
	$clu_end{$f[0]}{$f[1]} = "$f[3]_$f[4]";
	$clu_end{$f[1]}{$f[0]} = "$f[4]_$f[3]";
}
close IN;

# read hcluster.log
my %group;
my $flag = 0;
my $num = $ARGV[3];
open IN, "<$ARGV[2]" or die "Cannot open $ARGV[2]!\n";
while (<IN>) {
	chomp;
	next until /^[Group|Cluster_]/;
	if (/^Group number: (\d+)/) {
		$flag = 1 if $1 == $num;
		$flag = 0 if $1 != $num;
	} elsif ($flag == 1) {
		my @f = split(/[\t;]/, $_);
		my $l = 0;
		foreach my $c (@f[4 .. (@f - 1)]) {
			$l += $clu_len{$c};
		}
		@{$group{$l}} = @f[4 .. (@f - 1)] if $l > 0;
	} else {
		next;
	}
}
close IN;

# sort and output groups by length
print "#Cluster_id\tcontig_count\tcluster_length\trobustness[max:*]\tcontigs_order_orientation\n";
my $rank = 0;
foreach my $l (sort {$b <=> $a} keys %group) {
	$rank += 1;
	my @clu = @{$group{$l}};
	my $n = @clu;
	if ($n == 1) {
		if ($rank < 10) {
			print "Hcluster_0$rank\t$n\t$l\t\*\t$clu[0]\+\n";
		} else {
			print "Hcluster_$rank\t$n\t$l\t\*\t$clu[0]\+\n";
		}
	} else {
		my @tem;
		my $c1 = shift @clu;
		my $c2 = $clu[0];
		if ($clu_end{$c1}{$c2} =~ /head_/) {
			push @tem, "$c1-";
		} elsif ($clu_end{$c1}{$c2} =~ /tail_/) {
			push @tem, "$c1+";
		}
		while (@clu > 0) {
			$c2 = shift @clu;
			if ($clu_end{$c1}{$c2} =~ /_head/) {
				push @tem, "$c2+";
			} elsif ($clu_end{$c1}{$c2} =~ /_tail/) {
				push @tem, "$c2-";
			}
			$c1 = $c2;
		}
		if ($rank < 10) {
			print "Hcluster_0$rank\t$n\t$l\t\*\t" . join(";", @tem) . "\n";
		} else {
			print "Hcluster_$rank\t$n\t$l\t\*\t" . join(";", @tem) . "\n";
		}
	}
}
