#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl monoploid_select.pl Ht_chr_scaf_ctg.fa.len Ht_chr_scaf_ctg.fa > Ht_monoploid_chr.fa\n";

# read Ht_chr_scaf_ctg.fa.len and select the longest chr as the representative of each homologous group
my %len;
open IN, "<$ARGV[0]" or die "Cannot read $ARGV[0]!\n";
while (<IN>) {
	if (/(HtChr[0-1][0-9])\.(H[1-6])\t(\d+?)\s/) {
		$len{$1}{$3} = $2;
	} else {
		next;
	}
}
close IN;

my %selected;
foreach my $chr (keys %len) {
	my @tem = sort {$b <=> $a} keys %{$len{$chr}};
	my $id ="$chr\.$len{$chr}{$tem[0]}";
	$selected{$id} = 1;
}

# read Ht_chr_scaf_ctg.fa and output the 17 selected chr of pseudo-monoploid
my $head;
open IN, "<$ARGV[1]" or die "Cannot read $ARGV[1]!\n";
while (<IN>) {
	if (/^>(\S+?)\s/) {
		if ($selected{$1} == 1) {
			$head = $1;
			$head =~ s/\.H[1-6]//;
			print ">$head\n";
		} else {
			$head = "";
		}
	} elsif ($head ne "") {
		print "$_";
	} else {
		next;
	}
}
close IN;
