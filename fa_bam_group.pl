#!/usr/bin/perl
use strict;
use threads;

defined $ARGV[0] or die "Usage: perl fa_bam_group.pl Ht_ctg_to_monoploid.paf.group Ht_genome_ctg.fa Hthic.bwt2pairs.bam Ht_chr_group\n";

# read Ht_ctg_to_monoploid.paf.group
my %group;
open IN, "<$ARGV[0]" or die "$!\n";
while (<IN>) {
	chomp;
	my @t = split /[:\t]/, $_;
	push @{$group{$t[2]}}, $t[0];
}
close IN;
print STDERR "finished reading $ARGV[0] at " . localtime() . "\n";

# read Ht_genome_ctg.fa and Hthic.bwt2pairs.bam, output FASTA and BAM for each group
my $fasta = $ARGV[1];
my $bam = $ARGV[2];
my $out = $ARGV[3];
mkdir "$out" if not -d $out;
foreach my $chr (keys %group) {
	my %ids;
	$ids{"="} = 1;
	foreach my $id (@{$group{$chr}}) {
		$ids{$id} = 1;
	}
	mkdir "$out/$chr" if not -d "$out/$chr";
	print STDERR "start outputing FASTA and BAM of $chr at " . localtime() . "\n";
	threads->create(\&split_fa, $fasta, "$out/${chr}/${chr}_ctg\.fa", %ids) if not -z "$out/${chr}/${chr}_ctg\.fa";
	threads->create(\&split_bam, $bam, "$out/${chr}/${chr}_ctg\.bam", %ids) if not -z "$out/${chr}/${chr}_ctg\.bam";
}
while (threads->list(threads::running)) {
	foreach my $p (threads->list(threads::joinable)) {
		$p->join();
	}
	sleep 10;
}
print STDERR "finished outputing all FASTA and BAM of all groups at " . localtime() . "\n";

# sub routine for processing FASTA
sub split_fa {
	my $in = $_[0];
	my $out = $_[1];
	my (%ids) = @_[2 .. @_];
	open OUT, ">$out" or die "$!\n";
	open IN, "<$ARGV[1]" or die "$!\n";
	my $flag = 0;
	while (<IN>) {
		if (/^>(\S+)/) {
			if (exists $ids{$1}) {
				$flag = 1;
				print OUT "$_";
			} else {
				$flag = 0;
			}
		} elsif ($flag) {
			print OUT "$_";
		} else {
			next;
		}
	}
	close IN;
	close OUT;
}

# sub routine for processing BAM
sub split_bam {
	my $in = $_[0];
	my $out = $_[1];
	my (%ids) = @_[2 .. @_];
	open OUT, "| /vol1/agis/fanwei_group/metagenome/software/install/samtools-1.3/samtools view -bS -o $out" or die "$!\n";
	open IN, "/vol1/agis/fanwei_group/metagenome/software/install/samtools-1.3/samtools view -h $in |" or die "$!\n";
	while (<IN>) {
		if (/^\@SQ\sSN:(\S+?)\s/) {
			print OUT "$_" if exists $ids{$1};
		} elsif (/^\@/) {
			print OUT "$_";
		} else {
			my @t = split /\s/, $_;
			print OUT "$_" if exists $ids{$t[2]} and exists $ids{$t[6]};
		}
	}
	close IN;
	close OUT;
}

