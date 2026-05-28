#!/usr/bin/perl
use strict;
use List::Util qw(shuffle);

# parse input
defined $ARGV[0] or die "perl bed_random_misjoin.pl AthaHiC_100000_abs.bed.new 1>AthaHiC_100000_abs.bed.new.misjoined 2>AthaHiC_100000_abs.bed.new.break\n";

# read AthaHiC_100000_abs.bed.new
my %bed;
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split /\t/, $_;
	push @{$bed{$f[0]}}, join("\t", @f[1 .. 3]);
}
close IN;

# randomly split each chromosome
my (%bed2, %break);
foreach my $chr (sort keys %bed) {
	my @lines = @{$bed{$chr}};
	my $tot = @lines;
	my $frag_num = int(rand(10) + 1);
	my ($offset, $end) = (0, 0);
	foreach my $frag (1 .. ($frag_num - 1)) {
		my $id = "${chr}_${frag}";
		my $split = int(rand($tot) * 0.5 + $tot * 0.1);
		foreach my $line (@lines[0 .. ($split - 1)]) {
			my @f = split /\t/, $line;
			$end = $f[1];
			$f[0] -= $offset;
			$f[1] -= $offset;
			push @{$bed2{$id}}, join("\t", @f);
		}
		$offset = $end;
		$break{$id} = $offset;
		@lines = @lines[$split .. ($tot - 1)];
		$tot -= $split;
	}
	foreach my $line (@lines) {
		my @f = split /\t/, $line;
		$f[0] -= $offset;
		$f[1] -= $offset;
		my $id = "${chr}_${frag_num}";
		push @{$bed2{$id}}, join("\t", @f);
	}
}

# output split locations
foreach my $id (sort keys %break) {
	print STDERR "$id\t$break{$id}\n";
}

# randomly misjoin chromosome fragments
my @ids = keys %bed2;
@ids = shuffle @ids;
while (@ids > 1) {
	my $id1 = shift @ids;
	my $id2 = shift @ids;
	my $id = "${id1}\-${id2}";
	my $offset = 0;
	foreach my $line (@{$bed2{$id1}}) {
		my @f = split /\t/, $line;
		$offset = $f[1];
		print "$id\t$line\n";
	}
	foreach my $line (@{$bed2{$id2}}) {
		my @f = split /\t/, $line;
		$f[0] += $offset;
		$f[1] += $offset;
		print "$id\t" . join("\t", @f) . "\n";
	}
}
if (@ids) {
	my $id = shift @ids;
	foreach my $line (@{$bed2{$id}}) {
		print "$id\t$line\n";
	}
}
