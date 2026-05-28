#!/usr/bin/perl
use strict;

# parse input
defined $ARGV[0] or die "Usage: perl digest_genome.pl genome.fa enzyme:REsite(MboI:GATC) > genome_digest.gff\n";

# read genome.fa
my %seqs;
my $header;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$header = $1;
	} else {
		$seqs{$header} .= uc($_);
	}
}
close IN;

# digest genome and output as GFF
my ($enzyme, $site) = split /:/, $ARGV[1];
print "# Generic Feature Format Version 3 (GFF3)\n# seqid\tsource\ttype\tstart_position\tend_position\tscore\tstrand\tphase\tattributes\n";
foreach $header (sort keys %seqs) {
	my $seqf = $seqs{$header};
	while ($seqf =~ /$site/g) {
		my $end = pos($seqf);
		my $start = $end - length($site) + 1;
		print "$header\tREdigest\tREsite\t$start\t$end\t\.\t\+\t\.\tID=$enzyme\n";
	}
}
