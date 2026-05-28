#!/usr/bin/perl
use strict;
use Getopt::Long;

# parse input
my ($binsize, $binnum, $interval, $mininter, $minintra);
GetOptions (
	'binnum=i' => \$binnum,
	'interval=i' => \$interval,
	'mininter=f' => \$mininter,
	'minintra=f' => \$minintra
);
defined $ARGV[0] or die "
	Description: read Hi-C contact matrix and mapping of untigs to contig (optional), then infer the positions with assembly errors (misjoin).

	Author: Sen Wang, wangsen1993@163.com, 2022/8/12.

	Usage: perl asm_error_check.pl [--binnum 1] [--interval 5] [--mininter 0.1] [--minintra 0.1] combine_100000_abs.bed combine_100000.matrix [JJ_hifiasm_l3.p_utg_to_p_ctg.map] > JJ_hifiasm_l3.p_ctg.check
					
	--binnum length of one chunk, as number of bins (default 1 bin, i.e. 100000 bp)

	--interval distance between two chunks, as number of chunks (default 5 chunks, i.e. 5 * binnum * 100000 bp)

	--mininter minimum ratio of one normal HiC contact between two chunks (interval bins apart) to the median of all HiC contacts between any two chunks (interval bins apart), and any contact below this cutoff indicates an assembly error (default 0.1)

	--minintra minimum ratio of the HiC contact of one normal chunk to the median of all intra-chunk contacts, and any chunk below this cutoff will not be considered for analysis (default 0.1)
\n";
$binnum = 1 if not $binnum;
$binsize = $binnum * 100000;
$interval = 5 if not $interval;
$mininter = 0.1 if not $mininter;
$minintra = 0.1 if not $minintra;
print STDERR "chunk size: $binsize bp\ninter-chunk distance: $interval chunks\nminimum inter-chunk contact relative to its median: $mininter\nminimum intra-chunk contact relative to its median: $minintra\n";

# read HiC bin bed of contigs > interval size
my %bin_num;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	$bin_num{$t[0]} += 1;
}
close IN;

my $min_bin_num = $interval * $binnum;
foreach my $ctg (keys %bin_num) {
	if ($bin_num{$ctg} <= $min_bin_num) {
		delete $bin_num{$ctg};
		print STDERR "filter short contig: $ctg\n";
	}
}

my %bin_ids;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	next if not $bin_num{$t[0]};
	push @{$bin_ids{$t[0]}}, $t[3];
}
close IN;

my (%bin_ctg, %bin_map, %bin_ids_new);
my $rank;
foreach my $ctg (keys %bin_ids) {
	my @bins = @{$bin_ids{$ctg}};
	foreach my $bin (@bins) {
		$rank += 1;
		my $bin_new = int($rank / $binnum + 1);
		$bin_map{$bin} = $bin_new;
		push @{$bin_ids_new{$ctg}}, $bin_new;
		$bin_ctg{$bin_new} = $ctg;
	}
	$rank += $binnum;
}

foreach my $ctg (keys %bin_ids_new) {
	my @bins = @{$bin_ids_new{$ctg}};
	my %tem;
	foreach my $bin (@bins) {
		$tem{$bin} = 1;
	}
	@{$bin_ids_new{$ctg}} = sort {$a <=> $b} keys %tem;
}

# read HiC contact matrix
my %matrix;
foreach my $ctg (keys %bin_ids_new) {
	my @bins = @{$bin_ids_new{$ctg}};
	foreach my $bin1 (@bins) {
		foreach my $bin2 (@bins) {
			$matrix{$ctg}{$bin1}{$bin2} = 0 if $bin2 >= $bin1;
		}
	}
}

open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!";
while (<IN>) {
	chomp;
	my ($b1, $b2, $contact) = split /\t/, $_;
	my $bin1 = $bin_map{$b1};
	my $bin2 = $bin_map{$b2};
	next if not $bin_ctg{$bin1} or not $bin_ctg{$bin2};
	my $ctg1 = $bin_ctg{$bin1};
	my $ctg2 = $bin_ctg{$bin2};
	if ($ctg1 eq $ctg2) {
		if ($bin1 <= $bin2) {
			$matrix{$ctg1}{$bin1}{$bin2} += $contact;
		} else {
			$matrix{$ctg1}{$bin2}{$bin1} += $contact;
		}
	}
}
close IN;

my (%inter_contact, %intra_contact);
foreach my $ctg (keys %bin_ids_new) {
	my @bins = @{$bin_ids_new{$ctg}};
	foreach my $bin1 (@bins) {
		foreach my $bin2 (@bins) {
			#next if $matrix{$ctg}{$bin1}{$bin2} <= 0;
			push @{$inter_contact{$ctg}}, $matrix{$ctg}{$bin1}{$bin2} if ($bin2 - $bin1) == $interval;
			push @{$intra_contact{$ctg}}, $matrix{$ctg}{$bin1}{$bin2} if $bin2 == $bin1;
		}
	}
}

# read unitig_to_contig mappings
my %utg_pos;
if ($ARGV[2]) {
	open IN, "<$ARGV[2]" or die "Cannot open $ARGV[2]!\n";
	while (<IN>) {
		chomp;
		my @t = split /\t/, $_;
		next if not $bin_num{$t[13]};
		$utg_pos{$t[13]}{$t[14]} = $t[8];
	}
	close IN;
}

# calculate contact median and cutoff
sub median {
	my @contacts = @_;
	@contacts = sort {$a <=> $b} @contacts;
	my $n = scalar @contacts;
	my $med;
	if (($n % 2) == 0) {
		$med = ($contacts[$n / 2] + $contacts[$n / 2 - 1]) / 2;
	} else {
		$med = $contacts[int($n / 2)];
	}
	return $med;
}

my (%intra_med, %intra_low, %inter_med, %inter_low);
foreach my $ctg (keys %intra_contact) {
	$intra_med{$ctg} = &median(@{$intra_contact{$ctg}});
	$intra_low{$ctg} = $minintra * $intra_med{$ctg};
	$inter_med{$ctg} = &median(@{$inter_contact{$ctg}});
	$inter_low{$ctg} = $mininter * $inter_med{$ctg};
}

# scan the inter-bin HiC contact to find breaks
my %ctg_breaks;
foreach my $ctg (keys %bin_ids_new) {
	my @bins = @{$bin_ids_new{$ctg}};
	my $offset = $bins[0];
	my $bin1 = shift @bins;
	while (@bins > $interval) {
		my $bin2 = $bin1 + $interval + 1;
		my $pos = ($bin1 - $offset + 1) * $binsize + $interval * $binsize / 2;
		if ($matrix{$ctg}{$bin1}{$bin2} < $inter_low{$ctg} and $matrix{$ctg}{$bin1}{$bin1} > $intra_low{$ctg} and $matrix{$ctg}{$bin2}{$bin2} > $intra_low{$ctg}) {
			@{$ctg_breaks{$ctg}{$pos}} = ($matrix{$ctg}{$bin1}{$bin2}, $inter_low{$ctg}, $matrix{$ctg}{$bin1}{$bin1}, $matrix{$ctg}{$bin2}{$bin2}, $intra_low{$ctg});
		}
		$bin1 = shift @bins;
	}
}

# infer the accurate positions of assembly error
print "#Ctg_id\tError_loc\tInter_contact\tInter_cutoff\tIntra_contact1\tIntra_contact2\tIntra_cutoff\tBreak_pos\tUtg1_id\tUtg2_id\n";
foreach my $ctg (keys %bin_ids_new) {
	my @breaks = sort {$a <=> $b} keys %{$ctg_breaks{$ctg}};
	if (@breaks < $interval) {
		print "$ctg\tNo error\n";
	} else {
		my %span;
		my $p1 = shift @breaks;
		my $step = 1;
		while (@breaks) {
			my $p2 = shift @breaks;
			if (($p2 - $p1) == $binsize * $step) {
				$span{$p1} = $p2;
				$step += 1;
			} else {
				$p1 = $p2;
				$step = 1;
			}
		}
		my $flag = 0;
		foreach $p1 (sort keys %span) {
			if (($span{$p1} - $p1) >= ($interval - 1) * $binsize) {
				$flag += 1;
				my $err_loc;
				my $left = $p1 - $interval * $binsize;
				my $right = $span{$p1} + $interval * $binsize;
				my $dist = $right - $left;
				my $num = ($span{$p1} - $p1 + $binsize) / $binsize;
				if ($num % 2 == 0) {
					$err_loc = ($right + $left - $binsize) / 2;
				} else {
					$err_loc = ($right + $left) / 2;
				}
				my $break_pos;
				my $break_before = -2;
				if ($utg_pos{$ctg}) {	
					my @pos = sort {$a <=> $b} keys %{$utg_pos{$ctg}};
					foreach my $p (@pos) {
						if ($p >= $left and $p <= $right) {
							if ($p <= $err_loc and ($err_loc - $p) < $dist) {
								$dist = $err_loc - $p;
								$break_pos = $p;
							} elsif ($p > $err_loc and ($p - $err_loc) < $dist) {
								$dist = $p - $err_loc;
								$break_pos = $p;
							}
						}
					}
					foreach my $p (@pos) {
						$break_before += 1;
						last if $p == $break_pos;
					}
					$break_before = $pos[$break_before];
				}
				if ($break_pos) {
					print "$ctg\t$err_loc\t" . join("\t", @{$ctg_breaks{$ctg}{$err_loc}}) . "\t$break_pos\t$utg_pos{$ctg}{$break_before}\t$utg_pos{$ctg}{$break_pos}\n";
				} else {
					print "$ctg\t$err_loc\t" . join("\t", @{$ctg_breaks{$ctg}{$err_loc}}) . "\n";
				}
			}
		}
		if (not $flag) {
			print "$ctg\tNo error\n";
		}
	}
}
print STDERR "Done!\n";
