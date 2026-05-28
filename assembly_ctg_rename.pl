#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read 3d-dna.assembly and rename the contig fragments by taging the chromosome they belong to.
	
	Author: Sen Wang, wangsen1993@163.com, 2021/9/15.

	Usage: perl assembly_ctg_rename.pl z.1m.1st.cluster 3d-dna_draft.FINAL.assembly > 3d-dna_draft.FINAL.assembly.tagged
	\n";
}

# read mapped contigs to chromosomes in cluster format
my %ctg2chr;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	next if /^#/;
	chomp;
	my @f = split (/\t/, $_);
	my $chr = $f[0];
	my @ctgs = split (/;/, $f[4]);
	foreach my $ctg (@ctgs) {
		$ctg =~ s/[\+\-]//;
		$ctg2chr{$ctg} = $chr;
	}
}
close IN;

# read 3d-dna.assembly and rename the contig fragments
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	if (/^>(\w+)/) {
		if ($1 =~ /hic_gap/) {
			print $_;
			next;
		}
		my $new = "Un_$1";
	   	$new = "$ctg2chr{$1}_$1" if $ctg2chr{$1};
		$_ =~ s/$1/$new/;
		print $_;
	} else {
		print $_;
	}
}
close IN;
