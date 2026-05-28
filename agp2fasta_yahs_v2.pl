#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read AGP produced by YaHS and output the scaffold sequences in multi-line FASTA format.
	
	Author: Sen Wang, wangsen1993@163.com, 2023/10/07.

	Usage: perl agp2fasta_yahs_v2.pl yahs_JBAT.FINAL.agp contigs.fasta > yahs_JBAT.FINAL.fasta
	\n";
}

# read yahs_JBAT.FINAL.agp
my %scaffold;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split(/\t/, $_);
	if ($f[4] eq "W") {
		push @{$scaffold{$f[0]}}, join(":", @f[5 .. 8]);
	} else {
		push @{$scaffold{$f[0]}}, $f[5];
	}
}
close IN;

# read contigs.fasta
my %contig;
my $header;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$header = $1;
	} else {
		$contig{$header} .= $_;
	}
}
close IN;

# output scaffold sequences
foreach my $scaf (sort keys %scaffold) {
	my @lines = @{$scaffold{$scaf}};
	print ">$scaf\n";
	my $seq = "";
	foreach my $line (@lines) {
		my @t = split /:/, $line;
		my $ctg = $t[0];
		my $start = $t[1] - 1;
		my $len = $t[2] - $t[1] + 1;
		my $strand = $t[3];
		if ($strand eq '+') {
			die "Cannot get the sequence of $ctg! check $ARGV[1]!\n" if not $contig{$ctg};
			$seq .= substr($contig{$ctg}, $start, $len);
		} elsif ($strand eq '-') {
			die "Cannot get the sequence of $ctg! check $ARGV[1]!\n" if not $contig{$ctg};
			my $tem = substr($contig{$ctg}, $start, $len);
			$tem = reverse($tem);
			$tem =~ tr/ATCGatcg/TAGCtagc/;
			$seq .= $tem;
		} else {
			$seq .= "N" x $ctg;
		}
	}
	for (my $i = 0; $i < length($seq); $i += 60) {
		my $sub = substr($seq, $i, 60);
		print "$sub\n";
	}
}

