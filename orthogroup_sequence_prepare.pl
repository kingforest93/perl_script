#!/usr/bin/perl

=head1 Name

orthogroup_sequence_prepare.pl -- prepare pep or cds sequences for each orhtogroup

=head1 Description



=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage
  orthogroup_sequence_prepare.pl <Orthogroups.list> <pep_data_dir|cds_data_dir> <output_dir>
  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

 orthogroup_sequence_prepare.pl Orthogroups.tsv.single.copy.XLGsingle ../protein_data/ ./Orthogroups.tsv.single.copy.XLGsingle.pepDir
 orthogroup_sequence_prepare.pl Orthogroups.tsv.single.copy.XLGsingle ../CDS_data/ ./Orthogroups.tsv.single.copy.XLGsingle.cdsDir/

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
my $input_sequence_dir = shift;
my $output_dir = shift;
if (not -d $output_dir) {
	mkdir $output_dir;
}

my %OgGene;
my %GeneSeq;

open IN, $orthogroup_tsv_file || die "fail";
while (<IN>) {
	next if(/^Orthogroup/);
	chomp;
	my @t = split /\t/;
	
	my $OGid = shift @t;
	foreach my $str (@t) {
		my @geneId = split /,/, $str;
		foreach (@geneId) {
			s/^\s+//;
			s/\s+$//;
			#print STDERR "$_\n";
			push @{$OgGene{$OGid}}, $_;
		}
	}
}
close IN;

#print Dumper \%OgGene;


my @seq_files = glob("$input_sequence_dir/*");
foreach my $fasta_file (@seq_files) {
	Read_fasta($fasta_file, \%GeneSeq);
}


foreach my $OGid (sort keys %OgGene) {
	my $OG_p = $OgGene{$OGid};
	my $gene_count = @{$OG_p};
	#print STDERR "$OGid\t$gene_count\n";
	open OUT, ">$output_dir/$OGid.fa" || die "fail";
	foreach my $gene_id (sort @{$OG_p}) {
		#$gene_id =~ s/Aann\.mRNA_/Aann\.mRNA:/;
		my $gene_seq = $GeneSeq{$gene_id};
		#print STDERR length($gene_seq) . "\n";
		print OUT ">$gene_id\n$gene_seq";
	}
	close OUT;
}




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
		$name =~ s/:/_/;
		
		$/=">";
		my $seq = <IN>;
		chomp $seq;
		#$seq=~s/\s//g;
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

