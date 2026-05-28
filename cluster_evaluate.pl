#!/usr/bin/perl
use strict;
use Getopt::Long;

# parse input options
my ($low, $high, $help);
GetOptions (
	'low=f' => \$low,
	'high=f' => \$high,
	'h|help!' => \$help
);
if (not $ARGV[0] or $help) {
	die "
	Description: read EndHiC.cluster and mapped_contigs.cluster to reference chromosomes, as well as the contig lengthes, then evalutate the assembly status (chromosome, segment, misjoin) of each cluster relative to the corresponding chromosome, based on the aggregated length of contigs.

	Author: Sen Wang, wangsen1993@163.com, 2021/9/13.

	Usage: perl cluster_evaluate.pl [--low 0.05] [--high 0.85] contigs.len contigs_mapped_to_chromosomes.cluster z.EndHiC.results.summary.cluster > z.EndHiC.results.summary.cluster.evaluation
	
	ratio of shared contig length between Cluster_X and Chromosome_Y:
		< --low 0.05, the shared contig are debris of Chromosome_Y
		> --low 0.05 and < --high 0.85, the shared contigs are segment of Chromosome_Y
		> --high 0.85, the shared contigs are whole Chromosome_Y
	\n";
}
if (not $low) {
	$low = 0.05;
}
if (not $high) {
	$high = 0.85;
}

# read contig length
my %ctg_len;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my ($c, $l) = split (/\t/, $_);
	$ctg_len{$c} = $l;
}
close IN;

# read contigs_mapped_to_chromosomes.cluster
my (%chr_len, %ctg2chr);
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @f = split (/\t/, $_);
	$chr_len{$f[0]} = $f[2];
	my @ctgs = split(/;/, $f[4]);
	foreach my $c (@ctgs) {
		$c =~ s/[\+\-]//;
		$ctg2chr{$c} = $f[0];
	}
}
close IN;

# tag the unanchored contigs as Un
foreach my $ctg (keys %ctg_len) {
	if (not $ctg2chr{$ctg}) {
		$ctg2chr{$ctg} = "Un";
		$chr_len{"Un"} += $ctg_len{$ctg};
	} else {
		next;
	}
}

# read z.EndHiC.results.summary.cluster and evaluate the assembly status of each cluster
print "#Cluster_id\tCluster_length\tChromosome_id\tChromosome_length\tShared_contigs_length\tRatio_to_Cluster\tRatio_to_Chromosome\tAssembly_status\n";
open IN, "<$ARGV[2]" or die "Cannot open $ARGV[2]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @f = split (/\t/, $_);
	my $cluster = $f[0];
	my $cluster_len = $f[2];
	my @ctgs = split (/;/, $f[4]);
	my %shared;
	foreach my $c (@ctgs) {
		$c =~ s/[\+\-]//;
		$shared{$ctg2chr{$c}} += $ctg_len{$c};
	}
	foreach my $chr (sort keys %shared) {
		my $len = $shared{$chr};
		my $chromosome_len = $chr_len{$chr};
		my $r2cluster = sprintf("%.3f", $len / $cluster_len);
		my $r2chromosome = sprintf("%.3f", $len / $chromosome_len);
		my $status = "";
		if ($r2cluster >= $high) {
			if ($r2chromosome >= $high) {
				$status = "Chromosome";
			} elsif ($r2chromosome >= $low) {
				$status = "Segment";
			} else {
				$status = "Debris";
			}
		} else {
			if ($r2chromosome >= $high) {
				$status = "Misjoined_chromosomes";
			} elsif ($r2chromosome >= $low) {
				$status = "Misjoined_segments";
			} else {
				$status = "Misjoined_debris";
			}
		}
		print "$cluster\t$cluster_len\t$chr\t$chromosome_len\t$len\t$r2cluster\t$r2chromosome\t$status\n";
	}
}
close IN;
