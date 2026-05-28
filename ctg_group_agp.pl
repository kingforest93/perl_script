#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[1] or die "perl ctg_group_agp.pl input.agp scaffold_length_cutoff 1>group_ctg.ids 2>ungroup_ctg.ids\n";
my $cutoff = $ARGV[1];

# read agp
my (%scaf2len, %scaf2ctg);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @t = split /\t/, $_;
	$scaf2len{$t[0]} = $t[2];
	push @{$scaf2ctg{$t[0]}}, "$t[5]_$t[6]_$t[7]" if $t[5] ne "200";
}
close IN;

# group by length
my (%group, %ungroup);
foreach my $scaf (keys %scaf2len) {
	if ($scaf2len{$scaf} >= $cutoff) {
		foreach my $ctg (@{$scaf2ctg{$scaf}}) {
			my @t = split /_/, $ctg;
			$group{$t[0]} += 1;
		}
	} else {
		foreach my $ctg (@{$scaf2ctg{$scaf}}) {
			$ungroup{$ctg} += 1;
		}
	}
}

# output ids
foreach my $ctg (keys %group) {
	print STDOUT "$ctg\n";
}
foreach my $ctg (keys %ungroup) {
	my @t = split /_/, $ctg;
	if ($group{$t[0]}) {
		print STDERR join("\t", @t) . "\n";
	} else {
		print STDERR "$t[0]\n";
	}
}
