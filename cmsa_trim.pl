#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl cmsa_trim.pl Htub.Chr05.H1-6.single.copy.cds.muscle.fa maximum_gap_ratio(0.5) > Htub.Chr05.H1-6.single.copy.cds.muscle.trimmed.fa\n";

my $file = shift @ARGV;
my $max = shift @ARGV;
$max = 0.5 if not $max;

my %old_msa;
my $head;
open IN, "<$file" or die "$!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$head = $1;
	} else {
		my @t = split(//, $_);
		if (not $old_msa{$head}) {
			@{$old_msa{$head}} = @t;
		} else {
			@{$old_msa{$head}} = (@{$old_msa{$head}}, @t);
		}
	}
}
close IN;

my $n = scalar @{$old_msa{$head}};
my %new_msa;
foreach my $i (0 .. ($n - 1)) {
	my %column;
	my ($gap, $tot);
	foreach $head (keys %old_msa) {
		$column{$head} = $old_msa{$head}[$i];
		$tot += 1;
		$gap += 1 if $old_msa{$head}[$i] eq "-";
	}
	if ($gap / $tot <= $max) {
		foreach $head (keys %column) {
			if (not $new_msa{$head}) {
				$new_msa{$head} = $column{$head};
			} else {
				$new_msa{$head} .= $column{$head};
			}
		}
	}
}

foreach $head (keys %new_msa) {
	print ">$head\n$new_msa{$head}\n";
}
