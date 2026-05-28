#!/usr/bin/perl

=head1 Description

 ccsbam2fq.pl read BAM file of PacBio CCS and transform into FASTQ file, and output the length, accuracy (rq), and number of passes (np) of each ccs read.

=head1 Author

 Version 1.0, Date 2021/07/05.
 Sen Wang, wangsen1993@163.com.

=head1 Usage

 perl ccsbam2fq.pl -i ccs.reads.bam -o ccs.reads.fq.gz -s ccs.read.fq.gz.stat [-h]

=cut

use strict;
use Getopt::Long;
# parse input options
my ($inbam, $outfq, $outstat, $help);
GetOptions(
	"input|i=s"=>\$inbam,
	"output|o=s"=>\$outfq,
	"stat|s=s"=>\$outstat,
	"help|h!"=>\$help
);
if (not $inbam or $help) {
	die `pod2text $0`;
}
if (not $outfq) {
	$outfq = "$outfq\.fq.gz";
}
if (not $outstat) {
	$outstat = "$outfq\.stat";
}
# read BAM file, extract sequence and quality, and write into compressed FASTQ file
open IN, "samtools view $inbam |" or die "Cannot open $inbam!\n";
open OUT, "| gzip > $outfq" or die "Cannot create or write to $outfq!\n";
open STAT, ">$outstat" or die "Cannot create or write to $outstat!\n";
print STAT "#Read_id\tLength\tRead_accuracy\tNumber_passes\n";
while (<IN>) {
	next if /^@/;
	my @t = split(/\t/, $_);
	my $rd = $t[0]; # 1st column is read id
	my $sq = $t[9]; # 10th column is read sequence
	my $ql = $t[10]; # 11th column is read quality ASCII (Phred +33)
	my ($np, $rq);
	foreach my $t (@t[11 .. @t - 1]) {
		if ($t =~ /np/) {
			$np = $t; # the column of number of passes (subreads covering each ccs read)
		} elsif ($t =~ /rq/) {
			$rq = $t; # the column of read quality (average accuracy)
		} else {
			next;
		}
	}
	print OUT "\@$rd\t$rq\t$np\n$sq\n\+\n$ql\n";
	my $ln = length($sq);
	$np =~ s/np:i://;
	$rq =~ s/rq:f://;
	print STAT "$rd\t$ln\t$rq\t$np\n";
}
close IN;
close OUT;
close STAT;
