#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "perl bed_recalculate.pl AthaHiC_100000_abs.bed 1>AthaHiC_100000_abs.bed.new 2>AthaHiC_100000_abs.bed.len\n";

# read AthaHiC_100000_abs.bed
my (%bed, %len);
open IN, "<$ARGV[0]" or die "Cannnot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split /\t/, $_;
	my ($chr, $id) = split /_/, $f[0];
	$id = 0 if not $id;
	push @{$bed{$chr}{$id}}, "$chr\t$f[1]\t$f[2]\t$f[3]";
	$len{$chr}{$id} = $f[2];
}
close IN;

# recalculate coordinates belonging to the same chromosome
foreach my $chr (sort keys %len) {
	my @ids = sort {$a <=> $b} keys %{$len{$chr}};
	my $back = shift @ids;
	my $offset = 0;
	foreach my $line (@{$bed{$chr}{$back}}) {
		print "$line\n";
	}
	if (@ids >= 1) {
		foreach my $id (@ids) {
			$offset += $len{$chr}{$back};
			foreach my $line (@{$bed{$chr}{$id}}) {
				my @f = split /\t/, $line;
				$f[1] += $offset;
				$f[2] += $offset;
				print join("\t", @f) . "\n";
			}
			$back = $id;
		}
	}
}

# output the original length of each chromosome
foreach my $chr (sort keys %len) {
	my $tot = 0;
	foreach my $id (sort keys %{$len{$chr}}) {
		$tot += $len{$chr}{$id};
	}
	print STDERR "$chr\t$tot\n";
}
