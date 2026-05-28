#!/usr/bin/perl
use strict;

# load module
use Bio::SeqIO;
use Bio::Align::Utilities qw(aa_to_dna_aln);
use Bio::Seq::EncodedSeq;
use Bio::AlignIO;
use Bio::Tools::Run::Alignment::Clustalw;
use Bio::Align::DNAStatistics;
use Getopt::Long;

# parse cmd options
my ($in, $cds, $out, $help);
GetOptions (
	'input|i=s' => \$in,
	'cds|d=s' => \$cds,
	'output|o=s' => \$out,
	'help|h!' => \$help
);
if(not $in or not $cds or not $out or $help) {
	die "
	Usage: perl add_ka_and_ks_to_collinearity.pl -i collinearity_file -d cds_file -o output_file

	Modified from MCScanX downstream_analyses scripts, Sen Wang, wangsen1992@163.com, 2022/5/26.
	\n";
}

# open file
open (IN1, "<$cds") or die "Cannot open cds_file $cds!\n";
open (IN2, "<$in") or die "Cannot open collinearity_file $in!\n";
open (OUT1, ">$out") or die "Cannot write to output_file $out!\n";
my %seq = ();
my $num = 0;
my ($line, $head);

# read cds sequence
while ($line = <IN1>) {
	chomp $line;
	if ($line =~ /^>(\S+)/) {
		$head = $1;
		$num++;
	} else {
		$seq{$head} .= $line;
	}
}
close IN1;

# read collinearity file
while ($line = <IN2>) {
	chomp $line;
	if ($line eq "" or $line =~ /^#/) {
		print OUT1 "$line\n";
		next;
	}
	my @t = split ("\t", $line);
	if(not $seq{$t[1]} or not $seq{$t[2]}) {
		print OUT1 "$line\t-2\t-2\n";
	} else {
		open (OUT2, ">temp.cds") or die "Cannot write to temp.cds!\n";
		print OUT2 ">$t[1]\n$seq{$t[1]}\n>$t[2]\n$seq{$t[2]}\n";
		close OUT2;
		my $tempcds = Bio::SeqIO -> new(-file => 'temp.cds', -format => 'fasta');
		my %dna_hash;
		my $cds1 = $tempcds->next_seq;
		$dna_hash{$cds1 -> display_id} = $cds1;
		my $cds2 = $tempcds->next_seq;
		$dna_hash{$cds2 -> display_id} = $cds2;
		my $os_prot = Bio::SeqIO -> new(-file => '>temp.pro', -format => 'fasta');
		$os_prot -> write_seq($cds1 -> translate());
		$os_prot -> write_seq($cds2 -> translate());
		system("clustalw -infile='temp.pro'");
		my $get_prot_aln = Bio::AlignIO -> new(-file => "temp.aln", -format => "CLUSTALW");
		my $prot_aln = $get_prot_aln -> next_aln();
		my $dna_aln = &aa_to_dna_aln($prot_aln, \%dna_hash);
		eval{
			my $stats = Bio::Align::DNAStatistics -> new();
			my $result = $stats -> calc_all_KaKs_pairs($dna_aln);
			my ($Da, $Ds, $Dn, $N, $S, $S_d, $N_d);
			foreach my $an (@$result) {
     			foreach (sort keys %$an) {
          			next if /Seq/;
          			if ($_ eq "D_n") {$Dn = $an -> {$_}};
          			if ($_ eq "D_s") {$Ds = $an -> {$_}};
          			if ($_ eq "S_d") {$S_d = $an -> {$_}};
          			if ($_ eq "N_d") {$N_d = $an -> {$_}};
          			if ($_ eq "S") {$S = $an -> {$_}};
          			if($_ eq "N") {$N = $an -> {$_}};
     			}
   			}
			if ($Dn !~ /\d/) {$Dn = -2};
			if ($Ds !~ /\d/) {$Ds = -2};
			print OUT1 "$line\t$Dn\t$Ds\n";
		};
		if ($@) {
			print OUT1 "$line\t-2\t-2\n";
			next;
		}
	}
}
close IN2;
close OUT1;
system("rm temp.*");
