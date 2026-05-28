#!/usr/bin/perl
use strict;
defined $ARGV[0] or die "Usage: perl matrix2dist.pl ctg.lkmatrix\n";
# read link matrix
my @ctgs;
my (%mx, %self);
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @t = split /\t/, $_;
	my $c = shift @t;
	if ($c eq "contig") {
		@ctgs = @t;
	} else {
		my $l = 0;
		for ($l = 0; $l < @ctgs; $l += 1) {
			last if $ctgs[$l] eq $c;
		}
		$self{$ctgs[$l]} = $t[$l] if $t[$l] > 0;
		my $i = 0;
		for ($i = 0; $i < @t; $i += 1) {
			if ($t[$i] > 0) {
				$mx{$c}{$ctgs[$i]} = $t[$i];
			} else {
				$mx{$c}{$ctgs[$i]} = 0.001;
			}
		}
	}
}
close IN;
# normalize distance
my %mx_new;
foreach my $c1 (sort keys %self) {
	foreach my $c2 (sort keys %self) {
		my $min = $self{$c1};
		$min = $self{$c2} if $self{$c2} < $min;
		my $d = sprintf("%.3f", $min / $mx{$c2}{$c1});
		$mx_new{$c1}{$c2} = $d;
		$mx_new{$c2}{$c1} = $d;
	}
}
# output distance matrix
open OUT, ">$ARGV[0].distmx" or die "Cannot create or write to $ARGV[0].distmx\n";
print OUT "contig\t" . join("\t", sort keys %self) . "\n";
foreach my $c1 (sort keys %self) {
	my @line = ($c1);
	foreach my $c2 (sort keys %self) {
		push @line, $mx_new{$c1}{$c2};
	}
	print OUT join("\t", @line) . "\n";
}
close OUT;
# output distance between contig pairs
open OUT, ">$ARGV[0].distpr" or die "Cannot create or write to $ARGV[0].distpr\n";
my %pre;
foreach my $c1 (sort keys %self) {
	$pre{$c1} = 1;
	foreach my $c2 (sort keys %self) {
		next if $pre{$c2};
		print OUT "$c1\t$c2\t$mx_new{$c1}{$c2}\n";
	}
}
close OUT;
