#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl H.tub_HOG_select.pl H.tub_genome_chr.pep.gff.namelist N5.HOG.tsv column:copy(8:1 9:1 10:6 14:1) > N5.HOG.tsv.selected.copy\n";

my $list = shift @ARGV;
my $file = shift @ARGV;
my %select;
foreach my $c (@ARGV) {
	my ($a, $b) = split /:/, $c;
	$a -= 1;
	$select{$a} = $b;
}

my %map;
open IN, "<$list" or die "$!\n";
while (<IN>) {
	chomp;
	my ($a, $b) = split /\t/, $_;
	$map{$a} = $b;
}
close IN;

open IN, "<$file" or die "$!\n";
while (<IN>) {
	chomp;
	next if /^HOG/;
	my @t = split /\t/, $_;
	my @column = sort {$a <=> $b} keys %select;
	my @flag;
	foreach my $i (@column) {
		my @num = split /, /, $t[$i];
		if (@num == $select{$i}) {
			push @flag, 1;
		}
	}
	my $copy = @column;
	if (@flag == $copy) {
		my @new;
		my (%chr, %hap);
		foreach my $j (@t[0, @column]) {
			if ($j =~ /Htub/) {
				my @tem = split /, /, $j;
				foreach my $k (@tem) {
					if ($map{$k} =~ /Htub\.Chr(\d\d)\.H(\d)\./) {
						push @new, $map{$k};
						$chr{$1} += 1;
						$hap{$2} = 1;
					}
				}
			} else {
				push @new, $j;
			}
		}
		my $chr = keys %chr;
		my $hap = keys %hap;
		#print join("\t", @new) . "\n" if $chr ==1 and $hap == 6;
		print join("\t", @new) . "\n" if $chr == 1 or $hap == 6;
	}
}
close IN;
