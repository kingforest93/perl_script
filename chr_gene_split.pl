#!/usr/bin/perl
use strict;

defined $ARGV[0] or die "Usage: perl chr_gene_split.fa Ht_chr_combine.genes.gff.pep\n";

# read genes and separately output each chromosome
my ($id, $chr, $seq, $file);
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	if (/^>(.*)\n/) {
		my $header = $1;
		if ($id =~ /(Htub\.Chr\d\d)\.(H\d)/) {
			$chr = "$1_pep";
			$file = "$1\.$2\.pep";
			my $tem = "$1\.$2";
			$id =~ s/\s.*//;
			$id = "$tem\.$id";
			mkdir $chr if not -d $chr;
			open OUT, ">>$chr/$file" or die "$!\n";
			print OUT ">$id\n$seq";
			close OUT;
		}
		$id = $header;
		$seq = "";
	} else {
		$seq .= $_;
	}
}
close IN;

# output the last
if ($id =~ /(Htub\.Chr\d\d)\.(H\d)/) {
	$chr = "$1_pep";
	$file = "$1\.$2\.pep";
	mkdir $chr if not -d $chr;
	open OUT, ">>$chr/$file" or die "$!\n";
	print OUT ">$id\n$seq";
	close OUT;
}
