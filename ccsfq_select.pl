#!/usr/bin/perl
use strict;
use Getopt::Long;
# parse input options
my @fq,
my ($rd, $help);
GetOptions(
	'read|r=s' => \$rd,
	'fastq|f=s' => \@fq,
	'help|h!' => \$help
);
if (not $rd or $help) {
   die "
   Description: extract FASTQ sequences by the given read ids
   
   Author: Sen Wang, wangsen1993@163.com, 2021/6/20.

   Usage: perl ccsfq_select.pl -r reads.list -f ccs1.fq.gz ccs2.fq.gz ... > reads.list.fq
   \n";
}
my %ids;
open IN, "<$rd" or die "Cannot open $rd\n";
while (<IN>) {
	chomp;
	$ids{$_} = 1;
}
close IN;
foreach my $f (@fq) {
	open IN, "gunzip -c $f |" or die "Cannot open $f\n";
	my $ln = 0;
	my $flag = 0;
	while (<IN>) {
		chomp;
		$ln += 1;
		if ($ln % 4 == 1) {
			/^@(\S+)/;
			if ($ids{$1}) {
				print "$_\n";
				$flag = 1;
			} else {
				$flag = 0;
			}
		} else {
			if ($flag) {
				print "$_\n";
			} else {
				next;
			}
		}
	}
	close IN;
}

