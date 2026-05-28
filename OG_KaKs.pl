#!/usr/bin/perl

=head1 Name

OG_KaKs.pl -- calculate Ks for gene pairs in one OrthoGroup

=head1 Description

First align pep sequence, then transback to cds alignment.
Use KaKs_calculator with "-m GMYN" model.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage
  OG_KaKs.pl <pep_file> <cds_file>  <orthogroup.fa.muscle.diff>
  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

  OG_KaKs.pl Htub.Chr09.H1-6.pep Htub.Chr09.H1-6.cds OG0000765.fa.muscle.diff

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;


##get options from command line into variables and set default values
my ($Verbose,$Help);
GetOptions(
        "verbose"=>\$Verbose,
        "help"=>\$Help
);
die `pod2text $0` if (@ARGV == 0 || $Help);

my $pep_file = shift;
my $cds_file = shift;
my $diff_file = shift;

my $KaKs_Calculator = "/vol1/agis/fanwei_group/metagenome/software/install/KaKs_Calculator2.0/bin/Linux/KaKs_Calculator ";

my %CDS;
my %PEP;
Read_fasta($pep_file,\%PEP);
Read_fasta($cds_file,\%CDS);


#print Dumper \%Info;

##x1      chr1    +       110000  150000  y1      chr1    +       110000  150000  .       .       .
open IN, $diff_file || die "fail";
while (<IN>) {

	next if(/^\#/);

	my ($gene1,$gene2) = ($1,$2) if(/(\S+)_vs_(\S+)/);
	
	my $pep1 = $PEP{$gene1};
	my $pep2 = $PEP{$gene2};

	my $cds1 = $CDS{$gene1};
	my $cds2 = $CDS{$gene2};
	#print $line;
	print "#$gene1\t$gene2\n";
	
	open CDS, ">temp.pep.fa" || die "fail";
	print CDS ">$gene1\n$pep1\n>$gene2\n$pep2\n";
	close CDS;

	open CDS, ">temp.cds.fa" || die "fail";
	print CDS ">$gene1\n$cds1\n>$gene2\n$cds2\n";
	close CDS;
	
	`perl /public/agis/fanwei_group/fanwei/code/AGIS/GACP-2021/06.phylogeny_analysis/Tree_packages_and_tools/pep_cds_axt.pl temp.pep.fa temp.cds.fa`;
	`cat temp.cds.fa.muscle.axt >> $diff_file.axt`;
	
	#`perl $pep_cds_axt temp.pep.fa temp.cds.fa > temp.cds.axt`;
}
close IN;

`$KaKs_Calculator -i $diff_file.axt -o $diff_file.axt.KaKs -m GMYN`;


#read fasta file
#usage: Read_fasta($file,\%hash);
#############################################
sub Read_fasta{
	my $file=shift;
	my $hash_p=shift;
	
	my $total_num;
	open(IN, $file) || die ("can not open $file\n");
	$/=">"; <IN>; $/="\n";
	while (<IN>) {
		chomp;
		my $head = $_;
		my $name = $1 if($head =~ /^(\S+)/);
		
		$/=">";
		my $seq = <IN>;
		chomp $seq;
		$seq=~s/\s//g;
		$/="\n";
		
		if (exists $hash_p->{$name}) {
			warn "name $name is not uniq";
		}

		$hash_p->{$name} = $seq;

		$total_num++;
	}
	close(IN);
	
	return $total_num;
}

