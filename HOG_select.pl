#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl HOG_select.pl N5.HOG.tsv column:copy(8:1 9:1 10:6 14:1) > N5.HOG.tsv.selected.copy\n";

my $file = shift @ARGV;
my %select;
foreach my $c (@ARGV) {
	my ($a, $b) = split /:/, $c;
	$a -= 1;
	$select{$a} = $b;
}

open IN, "<$file" or die "$!\n";
while (<IN>) {
	chomp;
	next if /^HOG/;
	my @t = split /\t/, $_;
	my @column = sort {$a <=> $b} keys %select;
	my @new = ($t[0]);
	foreach my $i (@column) {
		my @num = split /, /, $t[$i];
		if (@num == $select{$i}) {
			push @new, $t[$i];
		}
	}
	my $copy = scalar(@column) + 1;
	if (@new == $copy) {
		print join("\t", @new) . "\n";
	}
}
close IN;
