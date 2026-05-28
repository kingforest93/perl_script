#!/usr/bin/perl
use strict;
print "Usage: perl merge_5k.pl SNP_P.value_Gene.txt\n" if !defined($ARGV[0]);
open IN, "<", $ARGV[0] or die "Cannot open $ARGV[0]!";
my ($line, $gene);
my (@tema, @temb);
my %SNPs;
while ($line = <IN>) {
	chomp;
	@tema = split /\t/, $line;
	$gene = $tema[2];
	@temb = split /_/, $tema[0];
	push @{$SNPs{$temb[0]}}, $temb[1];
}
close IN;
my ($chr, $pos, $len);
my $i = 0;
my @tem;
foreach $chr (keys %SNPs) {
	@{$SNPs{$chr}} = sort { $a <=> $b } @{$SNPs{$chr}};
	$len = @{$SNPs{$chr}};
	if ($len == 1) {
		@tem = undef;
	} else {
		while ($i < $len - 1) {
			if ($SNPs{$chr}[$i+1] - $SNPs{$chr}[$i] < 20000) {
				push @tem, ($SNPs{$chr}[$i], $SNPs{$chr}[$i+1]);
				$i = $i + 2;	
			} else {
				$i = $i + 1;
			}
		}
	}
	@{$SNPs{$chr}} = @tem;
}
foreach $chr (keys %SNPs) {
	foreach $pos (@{$SNPs{$chr}}) {
		print "$chr" . "_" . "$pos\t$gene" if $pos;
	}
}
