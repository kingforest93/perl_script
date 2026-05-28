#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "
	Description: read alignment PAF file produced by minimap2 and output the primary alignment statistics.

	Author: Sen Wang, wangsen1993@163.com, 2021/04/01.

	Usage: perl paf_aln_stat.pl input.paf > output.stat
	\n";
my ($pri_aln, $sec_aln, %score, %diverg, %seq_qur, %seq_ref);
# read and parse alignments in PAF format
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split /\t/, $_;
	$seq_qur{$f[0]} = "N" x $f[1] if not $seq_qur{$f[0]};
	$seq_ref{$f[5]} = "N" x $f[6] if not $seq_ref{$f[5]};
	substr($seq_qur{$f[0]}, $f[2], ($f[3] - $f[2] + 1), "X" x ($f[3] - $f[2] + 1));
	substr($seq_ref{$f[5]}, $f[7], ($f[8] - $f[7] + 1), "X" x ($f[8] - $f[7] + 1));
	$f[11] = sprintf("%d", $f[11] / 10) * 10;
 	$score{$f[11]} += 1;
	$f[16] =~ s/d[ve]:f://g;
	$f[16] = sprintf("%.1f", $f[16]);
	$diverg{$f[16]} += 1;
	if ($_ =~ /tp\:A\:P/) {
		$pri_aln += 1;
	} else {
		$sec_aln += 1;
	}
}
close IN;
#output statistics of alignments
my $aln = $pri_aln + $sec_aln;
print "#Total alignments:  $aln\n#Primary alignments: $pri_aln\n#Secondary alignments: $sec_aln\n";
print "#Alignment score\tNumber of alignments\n";
foreach my $s1 (sort {$b <=> $a} keys %score) {
	my $s2 = $s1 + 10;
	print "$s1\-$s2\t$score{$s1}\n";
}
print "#Alignment divergence\tNumber of alignments\n";
foreach my $d1 (sort {$a <=> $b} keys %diverg) {
	my $d2 = $d1 + 0.1;
	print "$d1\-$d2\t$diverg{$d1}\n";
}
#output statistics of qurey length and coverage
my $num_qur = keys %seq_qur;
my $len_qur = 0;
my $aln_qur = 0;
foreach my $q (keys %seq_qur) {
	$len_qur += length($seq_qur{$q});
	while ($seq_qur{$q} =~ /X/g) {$aln_qur += 1};
}
my $cov = sprintf("%.2f", $aln_qur / $len_qur * 100);
print "#Number of query sequences: $num_qur\n";
print "#Total length of query sequences: $len_qur\n";
print "#Total alignment length of query sequences: $aln_qur\n";
print "#Total coverage of query sequences: $cov\%\n";
#output statistics of reference length and coverage
my $num_ref = keys %seq_ref;
my $len_ref = 0;
my $aln_ref = 0;
foreach my $r (keys %seq_ref) {
	$len_ref += length($seq_ref{$r});
	while ($seq_ref{$r} =~ /X/g) {$aln_ref += 1};
}
$cov = sprintf("%.2f", $aln_ref / $len_ref * 100);
print "#Number of reference sequences: $num_ref\n";
print "#Total length of reference sequences: $len_ref\n";
print "#Total alignment length of reference sequences: $aln_ref\n";
print "#Total coverage of reference sequences: $cov\%\n";
