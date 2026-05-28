#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "Usage: perl manual_purge_duplicate.pl full_table.tsv PB.base.cov\n";
my %ctg_dp;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^#/;
	my @f = split /\t/, $_;
	if ($f[1] eq "Duplicated") {
		$f[2] =~ s/\w+_//g;
		push @{$ctg_dp{$f[2]}}, "$f[0]_$f[3]_$f[4]";
	} else {
		next;
	}
}
close IN;
my ($ctg, $flag);
my (@gene, @start, @end);
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
print "gene_contig\tposition\tdepth\n";
while (<IN>) {
	if (/^>(\w+)\s/) {
		$flag = 0;
		@start = ();
		@end = ();
		$ctg = $1;
		foreach (keys %ctg_dp) {
			if ($ctg eq $_) {
				$flag = 1;
				foreach (@{$ctg_dp{$ctg}}) {
					my @f = split /_/, $_;
					push @gene, $f[0];
					push @start, $f[1];
					push @end, $f[2];
#					print "$ctg\t$f[1]\t-1\t$f[0]\n";
#					print "$ctg\t$f[2]\t-1\t$f[0]\n";
				}
			} else {
				next;
			}
		}	
	} elsif ($flag == 1) {
		chomp;
		my @f = split /\t/, $_;
		foreach my $i (0 .. (@start - 1)) {
			if (($start[$i] <= $f[0] or $start[$i] <= $f[1]) and ($end[$i] >= $f[0] or $end[$i] >= $f[1])) {
				print "$gene[$i]_$ctg\t$f[0]\t$f[2]\n";
				print "$gene[$i]_$ctg\t$f[1]\t$f[2]\n";
			} else {
				next;
			}
		}
	} else {
		next;
	}
}
close IN;
