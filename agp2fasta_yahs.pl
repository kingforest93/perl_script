#!/usr/bin/perl
use strict;

# parse input options
if (not $ARGV[0] or $ARGV[0] eq "-h") {
	die "
	Description: read AGP produced by YaHS and output the scaffold sequences in multi-line FASTA format.
	
	Author: Sen Wang, wangsen1993@163.com, 2023/9/20.

	Usage: perl agp2fasta_yahs.pl yahs_JBAT.FINAL.agp contigs.fasta 1>yahs_JBAT.FINAL.agp 2>yahs_JBAT.FINAL.fasta
	\n";
}

# read yahs_JBAT.FINAL.agp
my %scaffold;
my $max = 102;
my %name;
foreach my $i (1 .. $max) {
	my $chr;
	if ($i <= 24 or $i >= 79) {
		$chr = sprintf("%d", $i / 6 + 1);
		$chr -= 1 if $i % 6 == 0;
	} elsif ($i >= 25 and $i <= 30) {
		$chr = 13;
	} elsif ($i >= 31 and $i <= 78) {
		$chr = sprintf("%d", $i / 6);
		$chr -= 1 if $i % 6 == 0;
	}
	$chr = "0$chr" if $chr <= 9;
	my $hap = $i % 6;
	$hap = 6 if $hap == 0;
	$name{"scaffold_${i}"} = "HtChr${chr}\.H${hap}";
}
#foreach my $i (sort {$name{$a} cmp $name{$b}} keys %name) {
#	print "$i\t$name{$i}\n";
#}
#die "done\n";
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]!\n";
while (<IN>) {
	chomp;
	my @f = split(/\t/, $_);
	if ($f[0] =~ /scaffold_(\d+)/ and $1 <= $max) {
		$f[0] = $name{$f[0]};
		print STDOUT join("\t", @f) . "\n";
		if ($f[4] eq "W") {
			push @{$scaffold{$f[0]}}, join(":", @f[5 .. 8]);
		} else {
			push @{$scaffold{$f[0]}}, $f[5];
		}
	}
}
close IN;

# read contigs.fasta
my %contig;
my $header;
open IN, "<$ARGV[1]" or die "Cannot open $ARGV[1]!\n";
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		$header = $1;
	} else {
		$contig{$header} .= $_;
	}
}
close IN;

# output scaffold sequences
foreach my $scaf (sort keys %scaffold) {
	my @lines = @{$scaffold{$scaf}};
	print STDERR ">$scaf\n";
	my $seq = "";
	foreach my $line (@lines) {
		my @t = split /:/, $line;
		my $ctg = $t[0];
		my $start = $t[1] - 1;
		my $len = $t[2] - $t[1] + 1;
		my $strand = $t[3];
		if ($strand eq '+') {
			die "Cannot get the sequence of $ctg! check $ARGV[1]!\n" if not $contig{$ctg};
			$seq .= substr($contig{$ctg}, $start, $len);
			substr($contig{$ctg}, $start, $len, "N" x $len);
		} elsif ($strand eq '-') {
			die "Cannot get the sequence of $ctg! check $ARGV[1]!\n" if not $contig{$ctg};
			my $tem = substr($contig{$ctg}, $start, $len);
			substr($contig{$ctg}, $start, $len, "N" x $len);
			$tem = reverse($tem);
			$tem =~ tr/ATCGatcg/TAGCtagc/;
			$seq .= $tem;
		} else {
			$seq .= "N" x $ctg;
		}
	}
	for (my $i = 0; $i < length($seq); $i += 60) {
		my $sub = substr($seq, $i, 60);
		print STDERR "$sub\n";
	}
}

# output unanchored contigs and fragments
my $rank = 0;
foreach my $ctg (sort keys %contig) {
	my $seq = $contig{$ctg};
	while ($seq =~ /([ATCG]+)/g) {
		$rank += 1;
		my $tem = $1;
		my $len = length($tem);
		my $end = pos($seq);
		my $start = $end - $len + 1;
		print STDERR ">HtUn.ctg$rank\n";
		for (my $i = 0; $i < $len; $i += 60) {
			my $sub = substr($tem, $i, 60);
			print STDERR "$sub\n";
		}
		
		print STDOUT "HtUn.ctg$rank\t1\t$len\t1\tW\t$ctg\t$start\t$end\t\+\n";
	}
}
