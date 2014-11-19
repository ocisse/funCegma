#!/usr/bin/perl -w


use strict;
use Carp;
use feature 'say'; 
use Data::Dumper; 
use Getopt::Long; 

# $Id$
=head1 NAME

wrapper for TBLASTN

=head1 USAGE

wrapperTBlastnOnChunk.pl <proteins.fa> <cluster|local> <cpu> 

if local specified, provides no. cpus to use 
./wrapperTBlastnOnChunk.pl 2StrCoreProteins.fa local 8

if cluster specified, provide the mem size to request
./wrapperTBlastnOnChunk.pl 2StrCoreProteins.fa cluster 8

8 means mem=8gb

=head1 OPTIONS

to be implemented

=head2 AUTHOR

Ousmane Cisse 
ousmanecis@gnmail.com

=cut

my $dir = ".";
my @list = ();

my $coreProteins = $ARGV[0];
my $mode = $ARGV[1];
my $size = $ARGV[2];

GetOptions(
	'h|help' => sub { exec('perldoc', $0);
			  exit(0);},
#	'p|proteins' => \$coreProteins,
#	'm|mode' => \$mode,
#	'c|cpu' => \$cpu,
#	's|size' => \$memsize,
);

unless (@ARGV >= 2){
	croak ("requires at least < proteins for TBLASTN > and < Option >");
}

if ($mode){
	unless ($size && ($size =~ /^[0-9]+$/)) {
		croak("local mode requires no. of cpus to use, please provide cpu!\ncluster mode requires mem size\n");
	}
}


if ( $mode =~ /local/i){
	$mode = 'local';
} elsif ($mode =~ /cluster/i){
	$mode = 'cluster';
}



opendir(DIR, $dir) || croak "cannot open$dir:$!\n";
while((my $filename  = readdir(DIR))){

	if ($filename =~ m/Chunk\d+.fa$/){
		#say $filename;
		push(@list, $filename); 
		}
	}
close DIR;

# run tblastn on each chunk
my $file = ''; 
foreach my $file (@list){
 	run("rm $file.sh $file.TBLASTN"); # just in case
 	run("echo \"module load ncbi-blast/2.2.29+\" > $file.sh");
 	run("echo \"makeblastdb -in $file -dbtype nucl -parse_seqids -out $file.db");
	if ($mode =~ /cluster/){
		 my $memsize = "$size"."gb"; 
		 run("echo \"tblastn -db $file.db -query $coreProteins -word_size 5 -max_target_seqs 5 -seg yes -lcase_masking -outfmt \'7 sseqid sstart send sframe bitscore qseqid\' > $file.TBLASTN\" >> $file.sh");
		 run("qsub -d `pwd` mem=$memsize $file.sh");
	} elsif ($mode =~ /local/){
		 run("tblastn -db $file.db -query $coreProteins -word_size 5 -max_target_seqs 5 -seg yes -lcase_masking -num_threads $size -outfmt \'7 sseqid sstart send sframe bitscore qseqid\' > $file.TBLASTN");
		}
}

# subs

sub run {
	my ($cmd) = @_; 
	say $cmd;
	system($cmd)==0 || croak "cannot run $cmd:$!\n";	

}
