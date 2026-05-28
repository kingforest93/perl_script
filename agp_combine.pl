#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl agp_combine.pl *.agp > combined.agp\n";

# read multiple agp files and store lines of chromosomes and short scaffolds
my (@chr_lines, @scaf_lines);
foreach my $file (@ARGV) {
	open IN, "<$file" or die "$!\n";
	while (<IN>) {
		chomp;
		$_ =~ /^scaffold_(\d+)\t/;
		my $rank = $1;
		if ($file =~ /04plus13/) {
			if ($rank <= 12) {
				push @chr_lines, $_;
			} else {
				push @scaf_lines, $_;
			}
		} else {
			if ($rank <= 6) {
				push @chr_lines, $_;
			} else {
				push @scaf_lines, $_;
			}
		}
	}
	close IN;
}

# rename and re-sort chromosomes and short scaffolds and output
my ($num, $id);
foreach my $line (@chr_lines) {
	my @t = split /\t/, $line;
	if (not $id) {
		$id = $t[0];
		$num = 1;
		print "$line\n";
	} else {
		if ($id ne $t[0]) {
			$num += 1;
			$id = $t[0];
			$t[0] = "scaffold_${num}";
			print join("\t", @t) . "\n";
		} else {
			$t[0] = "scaffold_${num}";
			print join("\t", @t) . "\n";
		}
	}
}

foreach my $line (@scaf_lines) {
	my @t = split /\t/, $line;
	if ($id ne $t[0]) {
		$num += 1;
		$id = $t[0];
		$t[0] = "scaffold_${num}";
		print join("\t", @t) . "\n";
	} else {
		$t[0] = "scaffold_${num}";
		print join("\t", @t) . "\n";
	}
}


