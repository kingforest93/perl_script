#!/usr/bin/perl
use strict;
use Getopt::Long;

# parse input options
if (not $ARGV[0]) {
	die "
	Description: read BAM and output the alignments matching or unmatching (-r) the given contigs.

	Author: Sen Wang, wangsen1993@163.com, 2021/6/20.
		
	Usage: perl BAM_select.pl [-r] contig.list raw.BAM > selected.sam
	\n";
}
my $r;
GetOptions (
	'r!' => \$r
);

# read contig list
my %ctg;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	/^(\S+)/;
	$ctg{$1} = 1;
}
close IN;

# filter BAM file by selecting the required alignments
open IN, "samtools view -h $ARGV[1] |" or die "Cannot open $$ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	if (/^@/) {
		if ($t[1] =~ /SN:(\S+)/) {
			if ($r) {
				if (not $ctg{$1}) {
					print "$_\n";
				}
			} else {
				if ($ctg{$1}) {
					print "$_\n";
				}
			}
		} else {
			print "$_\n";
		}
	} else {
		if ($r) {
			if (not $ctg{$t[2]} and not $ctg{$t[6]}) {
				print "$_\n";
			}
		} else {
			if ($ctg{$t[2]} and $ctg{$t[2]}) {
				print "$_\n";
			}
		}
	}
}
close IN;
