#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read manual_curated.cluster and the old scaffolds as AGP format, and output the new scaffolds in AGP format.
	
	Author: Sen Wang, wangsen1993@163.com, 2022/2/22.

	Usage: perl cluster_rejoin_agp.pl Ht_group_chr_scaf.list.new.cluster Ht_chr_scaf_ctg.agp > Ht_chr_scaf_ctg_cluster.agp
	\n";
}

# read Ht_group_chr_scaf.list.new.cluster
my %chromosomes;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split(/[\t;]/, $_);
	@{$chromosomes{$f[0]}} = @f[1 .. (@f - 1)];
}
close IN;

# read Ht_chr_scaf_ctg.agp
my %scaffolds;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @f = split(/\t/, $_);
	if ($f[4] eq "W") {
		push @{$scaffolds{$f[0]}}, join(":", @f[5 .. 8]);
	}
}
close IN;

# output chromosome-scaffolds as AGP
foreach my $chr (sort keys %chromosomes) {
	my @scafs = @{$chromosomes{$chr}};
	my @lines;
	foreach my $scaf (@scafs) {
		my $scaf_short = $scaf;
		$scaf_short =~ s/[\+\-]//;
		die "Cannot find the scaffold $scaf_short in $ARGV[1]!\n" if not $scaffolds{$scaf_short};
		if ($scaf =~ /\+$/) {
			foreach my $line (@{$scaffolds{$scaf_short}}) {
				push @lines, $line;
			}
		} elsif ($scaf =~ /\-$/) {
			foreach my $line (reverse @{$scaffolds{$scaf_short}}) {
				$line =~ tr/\+\-/\-\+/;
				push @lines, $line;
			}
		}
		delete $scaffolds{$scaf_short};
	}
	my ($begin, $end, $rank, $ctg, $start, $stop, $strand);
	my $last = pop(@lines);
	foreach my $line (@lines) {
		$rank += 1;
		$begin += 1;
		($ctg, $start, $stop, $strand) = split(/:/, $line);
		my $len = $stop - $start;
		$end = $begin + $len;
		print "$chr\t$begin\t$end\t$rank\tW\t$ctg\t$start\t$stop\t$strand\n";
		$rank += 1;
		$begin = $end + 1;
		$end = $begin + 199;
		print "$chr\t$begin\t$end\t$rank\tN\t200\tscaffold\tyes\tproximity_ligation\n";
		$begin = $end;
	}
	$rank += 1;
	$begin += 1;
	($ctg, $start, $stop, $strand) = split(/:/, $last);
	my $len = $stop - $start;
	$end = $begin + $len;
	print "$chr\t$begin\t$end\t$rank\tW\t$ctg\t$start\t$stop\t$strand\n";
}

# output short scaffolds and contigs as AGP
my ($ctg_num, $scaf_num) = (0, 0);
foreach my $scaf (sort keys %scaffolds) {
	my @lines = @{$scaffolds{$scaf}};
	die "Cannot find the scaffold $scaf in $ARGV[1]!\n" if not $scaffolds{$scaf};
	if (@lines == 1) {
		$ctg_num += 1;
		my $begin = 1;
		my $rank = 1;
		my ($ctg, $start, $stop, $strand) = split(/:/, $lines[0]);
		my $len = $stop - $start;
		my $end = $begin + $len;
		$scaf = "HtUn\.ctg$ctg_num";
		print "$scaf\t$begin\t$end\t$rank\tW\t$ctg\t$start\t$stop\t$strand\n";
	} else {
		$scaf_num += 1;
		$scaf = "HtUn\.scaf$scaf_num";
		my ($begin, $end, $rank, $ctg, $start, $stop, $strand);
		my $last = pop(@lines);
		foreach my $line (@lines) {
			$rank += 1;
			$begin += 1;
			($ctg, $start, $stop, $strand) = split(/:/, $line);
			my $len = $stop - $start;
			$end = $begin + $len;
			print "$scaf\t$begin\t$end\t$rank\tW\t$ctg\t$start\t$stop\t$strand\n";
			$rank += 1;
			$begin = $end + 1;
			$end = $begin + 199;
			print "$scaf\t$begin\t$end\t$rank\tN\t200\tscaffold\tyes\tproximity_ligation\n";
			$begin = $end;
		}
		$rank += 1;
		$begin += 1;
		($ctg, $start, $stop, $strand) = split(/:/, $last);
		my $len = $stop - $start;
		$end = $begin + $len;
		print "$scaf\t$begin\t$end\t$rank\tW\t$ctg\t$start\t$stop\t$strand\n";
	}
}
