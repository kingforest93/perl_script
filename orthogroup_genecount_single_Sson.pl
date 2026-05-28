#!/usr/bin/perl

=head1 Name

orthogroup_genecount_single.pl  -- get 1:1:1 single-copy orthogroup

=head1 Description



=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Version: 1.0,  Date: 2006-12-6
  Note:

=head1 Usage

  --verbose   output running progress information to screen  
  --help      output help information to screen  

=head1 Exmple

 perl ./orthogroup_genecount_single.pl Orthogroups.GeneCount.tsv 9 > Orthogroups.GeneCount.tsv.single.copy

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

my $orthogroup_genecount_file = shift;
my $Sson_col = shift;

open IN, $orthogroup_genecount_file || die "fail";
while (<IN>) {
	next if(/^Orthogroup/);
	my @t = split /\s+/;
	my $Sson_count = $t[$Sson_col - 1]; #XLG in 9th column
	my $num = @t - 2;
	my $status = 1;
	for (my $i=1; $i<=$num; $i++) {
		next if($i == ($Sson_col - 1)); ##XLG has a recent WGD
		if ($t[$i] != 1) {
			$status = 0;
		}
	}
	if ($status == 1 && $Sson_count > 0 && $Sson_count <= 2) {
		print $_;
	}

}
close IN;
