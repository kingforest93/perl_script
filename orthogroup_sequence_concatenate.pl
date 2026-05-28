#!/usr/bin/perl

=head1 Name

orthogroup_sequence_concatentate.pl -- concatentate pep or cds alignments for all the single-copy orhtogroups

=head1 Description

The result can be used to infer species tree and divergence time.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage

  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

 perl ./orthogroup_sequence_concatenate.pl Orthogroups.tsv.single.copy.XLGsingle.pepDir > Orthogroups.tsv.single.copy.XLGsingle.pep.muscle.concatentate.fa

 perl ./orthogroup_sequence_concatenate.pl Orthogroups.tsv.single.copy.XLGsingle.cdsDir > Orthogroups.tsv.single.copy.XLGsingle.cds.muscle.concatentate.fa


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

my $input_sequence_dir = shift;

my %Data;

my @seq_files = glob("$input_sequence_dir/*.muscle");
foreach my $fasta_file (@seq_files) {
	my %GeneSeq;
	Read_fasta($fasta_file, \%GeneSeq);
	
	foreach my $id (keys %GeneSeq) {
		my $seq = $GeneSeq{$id};
		my $species;
		if ($id =~ /^(\w\w\w\w)\./) {
			$species = $1;
		}
		if ($id =~ /^(Htub.Chr\d\d\.H\d)/) {
			$species = $1;
		}
		$Data{$species} .= $seq;
	}

}

foreach my $species (sort keys %Data) {
	my $seq = $Data{$species};
	Display_seq(\$seq);
	print ">$species\n$seq";
}





#display a sequence in specified number on each line
#usage: disp_seq(\$string,$num_line);
#		disp_seq(\$string);
#############################################
sub Display_seq{
	my $seq_p=shift;
	my $num_line=(@_) ? shift : 50; ##set the number of charcters in each line
	my $disp;

	$$seq_p =~ s/\s//g;
	for (my $i=0; $i<length($$seq_p); $i+=$num_line) {
		$disp .= substr($$seq_p,$i,$num_line)."\n";
	}
	$$seq_p = ($disp) ?  $disp : "\n";
}
#############################################




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

