#!/usr/bin/perl
use strict;
defined $ARGV[0] || die "Usage: perl blast_stat.pl blast.file.tbl\n";
my (%tot, %id, %cov);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	my @f = split /\t/, $_;
	next if $tot{$f[0]};
	$tot{$f[0]} = 1;
	my $i = sprintf "%.2f", $f[11];
	my $c = sprintf "%.2f", ($f[5] - $f[4]) / $f[1] * 100;
	$id{$i} += 1;
	$cov{$c} += 1;
}
close IN;
my $tot = keys %tot;
printf "Mapped seqs: %d\n", $tot;
print "Identity\tNum_seq\n";
foreach (sort {$a <=> $b} keys %id) {
	printf "%.2f%%\t%d\n", $_, $id{$_};
}
print "Coverage\tNum_seq\n";
foreach (sort {$a <=> $b} keys %cov) {
	printf "%.2f%%\t%d\n", $_, $cov{$_};
}
