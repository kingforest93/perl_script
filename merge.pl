#!/usr/bin/perl
use strict;
print "Usage: perl merge.pl SNP_P.value_Gene.txt\n" if !defined($ARGV[0]);
open IN, "<", $ARGV[0] or die "Cannot open $ARGV[0]!";
my ($line, $gene);
my @tem;
my %SNP_P;
while ($line = <IN>) {
	chomp;
	@tem = split /\t/, $line;
	$gene = $tem[2];
	$SNP_P{$tem[0]} = $tem[1];
}
close IN;
my ($i, $j, $k1, $d1, $k2, $d2);
my (@ks, @ps);
foreach $line (sort {$SNP_P{$a} <=> $SNP_P{$b}} keys %SNP_P) {
	push @ks, $line;
	push @ps, $SNP_P{$line};
}
for ($i=0; $i<@ks-1; $i++) {
	($k1, $d1) = split /_/, $ks[$i];
	for ($j=$i+1; $j<@ks; $j++) {
		($k2, $d2) = split /_/, $ks[$j];
		my $d = $d1 - $d2 > 0 ? $d1 - $d2 : -1*($d1 - $d2);
		if ($k1 eq $k2 and $d < 15000) {
			$ks[$j] = undef;
			$ps[$j] = undef;
		}
	}
}
for ($i=0; $i<@ks; $i++) {
	print "$ks[$i]\t$ps[$i]\t$gene" if $ks[$i];
}
