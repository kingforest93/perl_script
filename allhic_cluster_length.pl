#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "Usage: perl allhic_cluster_length.pl counts.txt clusters.txt\n";
my %ctg_len;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	next if /^#/;
	my @t = split /\t/, $_;
	$ctg_len{$t[0]} = $t[2];
}
close IN;
my ($tot_len, $tot_num);
open IN, "$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	next if /^#/;
	my @t = split /[\t\s]/, $_;
	my $chr = shift @t;
	my $num = shift @t;
	$tot_num += $num;
	my $len = 0;
	foreach (@t) {
		$len += $ctg_len{$_};
	}
	print "$chr\t$num\t$len\n";
	$tot_len += $len;
}
close IN;
print "All\t$tot_num\t$tot_len\n";
