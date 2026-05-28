#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl agp_polish.pl Ht_all_ctg_nucleus.fa.len Ha_NC_035433.2_Ht_ctg_yahs_JBAT.FINAL.agp prefix(replace 'scaffold') > Ha_NC_035433.2_Ht_ctg_yahs_JBAT.FINAL.polished.agp\n";

# read Ht_all_ctg_nucleus.fa.len
my %lens;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$lens{$t[0]} = $t[1];
}
close IN;

# read Ha_NC_035433.2_Ht_ctg_yahs_JBAT.FINAL.agp
my %scaffold;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$t[0] =~ s/scaffold_//;
	if ($lens{$t[5]} > 0) {
		push @{$scaffold{$t[0]}}, join("\t", @t[4 .. 8]);
	}
}
close IN;

# output polished agp
my $prefix = $ARGV[2];
foreach my $id (sort {$a <=> $b} keys %scaffold) {
	my @lines = @{$scaffold{$id}};
	if (@lines == 1) {
		$id = "${prefix}_ctg_${id}";
		my $line = $lines[0];
		my @t = split /\t/, $line;
		my $len = $t[3] - $t[2] + 1;
		$line =~ s/\-/\+/;
		print "$id\t1\t$len\t1\t$line\n";
	} else {
		$id = "${prefix}_scaf_${id}";
		my ($line, $start, $end, $rank);
		while (@lines > 1) {
			$line = shift @lines;
			my @t = split /\t/, $line;
			my $len = $t[3] - $t[2];
			$start = $end + 1;
			$end = $start + $len;
			$rank += 1;
			print "$id\t$start\t$end\t$rank\t$line\n";
			$len = 199;
			$start = $end + 1;
			$end = $start + $len;
			$rank += 1;
			print "$id\t$start\t$end\t$rank\tN\t200\tscaffold\tyes\tproximity_ligation\n";
		}
		$line = shift @lines;
		my @t = split /\t/, $line;
		my $len = $t[3] - $t[2];
		$start = $end + 1;
		$end = $start + $len;
		$rank += 1;
		print "$id\t$start\t$end\t$rank\t$line\n";
	}
}
