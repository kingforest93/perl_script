#!/usr/bin/perl

=head1 Name

orthoFinder_HierarchicalTsv_to_genecount.pl -- convert Hierarchical tsv file to gene count file

=head1 Description

The result is used for CAFE gene family expansion and extraction analysis.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage

  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

 orthoFinder_HierarchicalTsv_to_genecount.pl N2.tsv 6 > N2.tsv.genecount 2> N2.tsv.genecount.total


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

my $orthogroup_tsv_file = shift;
my $outgroup = shift; # outgroup column


open IN, $orthogroup_tsv_file || die "fail";
while (<IN>) {
	if(/^HOG/){
		my @t = split /\t/, $_;
		$t[0] = "FAMILYDESC";
		$t[1] = "FAMILY";
		splice @t, ($outgroup - 1), 1;
		splice @t, 2, 1;
		#s/^HOG\s+OG\s+Gene Tree Parent Clade/FAMILYDESC\tFAMILY/;
		#print "FAMILYDESC\tFAMILY\tArctium_lappa	Artemisia_annua	Carthamus_tinctorius	Chrysanthemum_nankingense	Cichorium_endivia	Cichorium_intybus	Cynara_cardunculus	Erigeron_breviscapus	Erigeron_canadensis	Helianthus_annuus	Lactuca_sativa	Mikania_micrantha	Smallanthus_sonchifolius	Stevia_rebaudiana	Taraxacum_kok-saghyz	Taraxacum_mongolicum\n";
		print join("\t", @t);
		next;
	}

	my @t = split /\t/, $_;
	splice @t, ($outgroup - 1), 1;
	my $HOG = shift @t;
	my $OG = shift @t;
	my $OG_clade = shift @t;
	
	my $output = "$OG$OG_clade\t$HOG";
	#my $num = @t;
	my $total_gene_count = 0;
	my $total_gene_species = 0;
	#print $HOG."\t$num\n";
	for(my $i = 0; $i < @t; $i++) {
		my $str = $t[$i];
		my @geneId = split /,/, $str;
		my $gene_count = 0;
		foreach (@geneId) {
			s/^\s+//;
			s/\s+$//;
			$gene_count ++ if(/\S+/);
		}
		#if($i != 6 && $i != 17){
			$output .= "\t$gene_count" ;
			$total_gene_count += $gene_count;
			$total_gene_species ++ if($gene_count > 0);
			#}
	}
	print STDERR "$HOG\t$total_gene_count\t$total_gene_species\n";
	print $output."\n";
}
close IN;

