#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "
	Description: read multiple sequences in FASTA format and output the length statistics of total, max, min, L10,L20,...,L99 and N10,N20,...,N99.

	Author: Sen Wang, wangsen1993@163.com, 2021/1/7.

	Usage: perl asm_stat.pl asembly.fasta > asembly.fasta.stat
\n";
my ($h, $tot_num, $tot_len);
my %lens;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	if (/^>(\S+)/) {
		$tot_num += 1;
		$h = $1;
		next;
	}
	chomp;
	$tot_len += length($_);
	$lens{$h} += length($_);
}
close IN;
print "Number of sequences: $tot_num\nTotal length: $tot_len\n";
my %ctg;
my @lens = sort {$b <=> $a} values %lens;
$ctg{'Max'} = $lens[0];
$ctg{'Min'} = $lens[$tot_num - 1];
my ($num, $tem);
foreach $num (1 .. scalar @lens) {
	$tem += $lens[$num - 1];
	if ($tem > 0 and $tem < 0.1 * $tot_len) {
		$ctg{'L10'} = $num + 1;
		$ctg{'N10'} = $lens[$num];
	} elsif ($tem > 0.1 * $tot_len and $tem < 0.2 * $tot_len) {
		$ctg{'L20'} = $num + 1;
		$ctg{'N20'} = $lens[$num];
	} elsif ($tem > 0.2 * $tot_len and $tem < 0.3 * $tot_len) {
		$ctg{'L30'} = $num + 1;
		$ctg{'N30'} = $lens[$num];
	} elsif ($tem > 0.3 * $tot_len and $tem < 0.4 * $tot_len) {
		$ctg{'L40'} = $num + 1;
		$ctg{'N40'} = $lens[$num];
	} elsif ($tem > 0.4 * $tot_len and $tem < 0.5 * $tot_len) {
		$ctg{'L50'} = $num + 1;
		$ctg{'N50'} = $lens[$num];
	} elsif ($tem > 0.5 * $tot_len and $tem < 0.6 * $tot_len) {
		$ctg{'L60'} = $num + 1;
		$ctg{'N60'} = $lens[$num];
	} elsif ($tem > 0.6 * $tot_len and $tem < 0.7 * $tot_len) {
		$ctg{'L70'} = $num + 1;
		$ctg{'N70'} = $lens[$num];
	} elsif ($tem > 0.7 * $tot_len and $tem < 0.8 * $tot_len) {
		$ctg{'L80'} = $num + 1;
		$ctg{'N80'} = $lens[$num];
	} elsif ($tem > 0.8 * $tot_len and $tem < 0.9 * $tot_len) {
		$ctg{'L90'} = $num + 1;
		$ctg{'N90'} = $lens[$num];
	} elsif ($tem > 0.9 * $tot_len and $tem < 0.95 * $tot_len) {
		$ctg{'L95'} = $num + 1;
		$ctg{'N95'} = $lens[$num];
	} elsif ($tem > 0.95 * $tot_len and $tem < 0.99 * $tot_len) {
		$ctg{'L99'} = $num + 1;
		$ctg{'N99'} = $lens[$num];
	} else {
		next;
	}
}
print "Maximum sequence: $ctg{'Max'}\n";
print "L10: $ctg{'L10'}; N10: $ctg{'N10'}\n";
print "L20: $ctg{'L20'}; N20: $ctg{'N20'}\n";
print "L30: $ctg{'L30'}; N30: $ctg{'N30'}\n";
print "L40: $ctg{'L40'}; N40: $ctg{'N40'}\n";
print "L50: $ctg{'L50'}; N50: $ctg{'N50'}\n";
print "L60: $ctg{'L60'}; N60: $ctg{'N60'}\n";
print "L70: $ctg{'L70'}; N70: $ctg{'N70'}\n";
print "L80: $ctg{'L80'}; N80: $ctg{'N80'}\n";
print "L90: $ctg{'L90'}; N90: $ctg{'N90'}\n";
print "L95: $ctg{'L95'}; N95: $ctg{'N95'}\n";
print "L99: $ctg{'L99'}; N99: $ctg{'N99'}\n";
print "Minimum sequence: $ctg{'Min'}\n";
