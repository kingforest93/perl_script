#!/usr/bin/perl
my %map;
open IN, "<$ARGV[0]";
while (<IN>) {
	chomp;
	my ($new, $old) = split /\t/, $_;
	$map{$old} = $new;
}
close IN;

open IN, "<$ARGV[1]";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	next if not $map{$t[0]};
	$t[0] = $map{$t[0]};
#	$t[5] = $map{$t[5]};
	print join("\t", @t) . "\n";
}
close IN;
