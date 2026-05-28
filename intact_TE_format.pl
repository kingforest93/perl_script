#!/usr/bin/perl
use strict;


# parse input options
defined $ARGV[0] or die "
	Description: read the combined EDTA.intact.gff from mutiple chunks, remove the redundant annotation lines of LTR-RT, and uniqually rename the ID and Name in attributes.

	Author: Sen Wang, wangsen1993@163.com, 2022/4/22.

	Usage: perl intact_TE_format.pl TH_ctg.fa.EDTA.intact.gff3 > TH_ctg.fa.EDTA.intact.formated.gff3
\n";

# read and rename
my ($te, $ltr, $tir, $helitron) = (0, 0, 0, 0);
print "## GFF Version 3\n";
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!";
while (<IN>) {
	my @f = split /\t/, $_;
	my @a = split /;/, $f[8];
	if ($f[2] =~ /repeat_region/) {
		$te += 1;
		$ltr += 1;
		$a[0] = "ID=TE_struc_$te";
		$a[1] = "Name=LTR_$ltr";
		$f[8] = join(";", @a);
		$f[2] = "LTR_retrotransposon";
		print join("\t", @f);
	} elsif ($f[2] =~ /TIR_transposon/) {
		$te += 1;
		$tir += 1;
		$a[0] = "ID=TE_struc_$te";
		$a[1] = "Name=TIR_$tir";
		$f[8] = join(";", @a);
		$f[2] = "TIR_transposon";
		print join("\t", @f);
	} elsif ($f[2] =~ /helitron/) {
		$te += 1;
		$helitron += 1;
		$a[0] = "ID=TE_struc_$te";
		$a[1] = "Name=Helitron_$helitron";
		$f[8] = join(";", @a);
		$f[2] = "Helitron";
		print join("\t", @f);
	} else {
		next;
	}
}
close IN;
print STDERR "Total TE number: $te\nLTR-RT number: $ltr\nTIR-TE number: $tir\nHelitron-TE number: $helitron\n";