#!/usr/bin/perl
use strict;
defined $ARGV[0] || die "Usage: perl bam_stat.pl file.bam\n";
my ($tot, $un);
my (%id, %cov);
open IN, "samtools view $ARGV[0] |" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^@/;
	$tot += 1;
	my @f = split /\t/, $_;
	if ($f[5] eq "*") {
			$un += 1;
		   	next;
	}
	my ($al, $ms, $mc) = (0, 0, 0);
	if ($f[11] =~ /NM:i:(\d+)/) {
		$ms = $1;
	}
	while ($f[5] =~ /(\d+)M/g) {
		$mc += $1;
	}
	while ($f[5] =~ /(\d+)[MID]/g) {
		$al += $1;
	}
	my $i = sprintf "%.2f", ($al - $ms) / $al * 100;
	my $c = sprintf "%.2f", $mc / length($f[9]) * 100;
	$id{$i} += 1;
	$cov{$c} += 1;
}
close IN;
printf "Total reads: %d\nUnmapped reads: %d\nMapping rate: %.2f%%\n", $tot, $un, ($tot - $un) / $tot * 100;
print "Identity\tNum_read\n";
foreach (sort {$a <=> $b} keys %id) {
	printf "%.2f%%\t%d\n", $_, $id{$_};
}
print "Coverage\tNum_read\n";
foreach (sort {$a <=> $b} keys %cov) {
	printf "%.2f%%\t%d\n", $_, $cov{$_};
}
