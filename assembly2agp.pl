#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read 3D-DNA ASSEMBLY file and convert to AGP format.

	Author: Sen Wang, wangsen1993@163.com, 2021/8/21.

	Usage: perl assembly2agp.pl FINAL.assembly > FINAL.agp
	\n";
}

# read assembly file
my (%scaffolds, %fragments, %lengths);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	if (/^>(.*)/) {
		my @tem = split(/\s/, $1);
		$fragments{$tem[1]} = $tem[0];
		$lengths{$tem[1]} = $tem[2];
	} else {
		my @tem = split(/\s/, $_);
		my $l = 0;
		my @t = @tem;
		foreach my $i (@tem) {
			$i =~ s/\-//;
			$l += $lengths{$i};
		}
		@{$scaffolds{$l}} = @t;
	}
}
close IN;

# output agp
my $scaf = 0;
foreach my $s (sort {$b <=> $a} keys %scaffolds) {
	$scaf += 1;
	my $start = 1;
	my $end = 1;
	my $rank = 0;
	my $strand = "";
	foreach my $c (@{$scaffolds{$s}}) {
		$rank += 1;
		if ($c =~ /\-/) {
			$c =~ s/\-//;
			$strand = "-";
			$end = $start + $lengths{$c} - 1;
			print join("\t", ("Scaffold_$scaf", $start, $end, $rank, "W", $fragments{$c}, 1, $lengths{$c}, $strand)) . "\n";
			$start = $end + 1;
		} elsif ($fragments{$c} =~ /hic_gap/) {
			$strand = "map";
			$end = $start + $lengths{$c} - 1;
			print join("\t", ("Scaffold_$scaf", $start, $end, $rank, "U", $lengths{$c}, "contig", "yes", $strand)) . "\n";
			$start = $end + 1;
		} else {
			$strand = "+";
			$end = $start + $lengths{$c} - 1;
			print join("\t", ("Scaffold_$scaf", $start, $end, $rank, "W", $fragments{$c}, 1, $lengths{$c}, $strand)) . "\n";
			$start = $end + 1;
		}
	}
}
