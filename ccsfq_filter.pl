#!/usr/bin/perl
use strict;
use Getopt::Long;
#parse input options
my ($in, $out, $len_cutoff, $rq_cutoff, $help);
GetOptions (
	'input|i=s' => \$in,
	'output|o=s' => \$out,
	'length|l=i' => \$len_cutoff,
	'quality|q=f' => \$rq_cutoff,
	'help|h!' => \$help
);
if (not $in or $help) {
	die "
	Description: read PacBio CCS FASTAQ (gzipped) and select the reads with length and read accuracy above given cutoff.
	
	Author: Sen Wang, wangsen1993@163.com, 2021/7/8.

	Usage: perl ccsfq_filter.pl -i ccs.read.fq[.gz] -o new.ccs.read.fq.gz -l length -q read_accuracy -h
	\n";
}
#determine file type and prepare output
if ($in =~ /\.gz/) {
	open IN, "gunzip -c $in |" or die "Cannot open $in!\n";
} else {
	open IN, "<$in" or die "Cannot open $in!\n";
}
open OUT, "| gzip > $out" or die "Cannot write to $out!\n";
#read file, stat and output
my $n = 0;
my ($id, $seq, $sep, $len, $rq);
while (<IN>) {
	$n += 1;
	chomp;
	if ($n % 4 == 1) {
		$id = $_;
		$id =~ /rq:f:([01]\.\d+)/;
		$rq = $1;
	} elsif ($n %4 == 2) {
		$seq = $_;
		$len = length($_);
	} elsif ($n % 4 == 3) {
		$sep = $_;
	} else {
		if ($len > $len_cutoff and $rq > $rq_cutoff) {
			print OUT "$id\n$seq\n$sep\n$_\n";
		}
	}
}
close IN;
close OUT;
