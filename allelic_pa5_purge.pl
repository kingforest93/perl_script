#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "perl allelic_pa5_purge.pl Ht_l0.2hap_nucleus_ctg.allelic Hthic.allValidPairs.pa5 > Hthic.allValidPairs.pa5.purged\n";

# read Ht_l0.2hap_nucleus_ctg.allelic
my %alle;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	$_ =~ s/:\d+//g;
	my @t = split /\t/, $_;
	shift @t;
	if (@t <= 1) {
		next;
	} elsif (@t == 2) {
		$alle{$t[0]}{$t[1]} = 1;
	} else {
		my $n = scalar @t;
		foreach my $i (0 .. ($n - 2)) {
			foreach my $j (($i + 1) .. ($n - 1)) {
				$alle{$t[$i]}{$t[$j]} = 1;
			}
		}
	}
}
close IN;

# read Hthic.allValidPairs.pa5 and purge inter-allelic links
my $remove = 0;
open IN, "<$ARGV[1]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	if ($alle{$t[1]}{$t[3]} == 1 or $alle{$t[3]}{$t[1]} == 1) {
		$remove += 1;
		next;
	} else {
		print STDOUT "$_\n";
	}
}
close IN;
print STDERR "Removed $remove inter-allele valid-pairs!\n";
