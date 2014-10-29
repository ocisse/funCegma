#!/usr/bin/perl -w


use Carp; 
use strict;
use Data::Dumper; 
use feature 'say';


my ($group,$fasta) = @ARGV;; 


open F,$fasta || croak "cannot open $fasta:$!\n";
while(<F>){
chomp; 
	if (/^>/){
		my $old = $_;
		   $old =~s/^>//;
		say ">$old\_\_$group";

	}
	else {
		say;
	}
}
close F;
