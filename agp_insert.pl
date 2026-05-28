#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl agp_insert.pl raw.agp position(chromosome_id:contig_rank) insert_contig_id > raw_inserted.agp\n";

my ($chr, $pos) = split /:/, $ARGV[1];
my $ctg = $ARGV[2];

# read original agp
my %scaffolds;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	if ($t[4] eq "W") {
		push @{$scaffolds{$t[0]}}, join(":", @t[5 .. 8]);
	} else {
		push @{$scaffolds{$t[0]}}, $t[5];
	}
}
close IN;

# output new agp
foreach my $scaf (sort {$a cmp $b} keys %scaffolds) {
	next if $scaf eq $ctg;
	my ($start, $end, $rank, $len) = (1, 0, 0, 0);
	foreach my $line (@{$scaffolds{$scaf}}) {
		my @t = split /:/, $line;
		if (@t > 1) {
			$len = $t[2] - $t[1];
			$end = $start + $len;
			$rank += 1;
			print "$scaf\t$start\t$end\t$rank\tW\t$t[0]\t$t[1]\t$t[2]\t$t[3]\n";
		} else {
			$len = 100 - 1;
			$end = $start + $len;
			$rank += 1;
			print "$scaf\t$start\t$end\t$rank\tU\t100\tscaffold\tyes\tproximity_ligation\n";
		}
		$start = $end + 1;
		if ($scaf eq $chr and $rank == $pos) {
			my @insert = @{$scaffolds{$ctg}};
			my @f = split /:/, $insert[0];
			$len = $f[2] - $f[1];
			$end = $start + $len;
			$rank += 1;
			print "$scaf\t$start\t$end\t$rank\tW\t$f[0]\t$f[1]\t$f[2]\t$f[3]\n";
			$start = $end + 1;
			$len = 100 - 1;
			$end = $start + $len;
			$rank += 1;
			print "$scaf\t$start\t$end\t$rank\tU\t100\tscaffold\tyes\tproximity_ligation\n";
			$start = $end + 1;
		}
	}
}
