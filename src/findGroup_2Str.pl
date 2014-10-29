#!/usr/bin/perl -w 

use feature 'say'; 
use Data::Dumper; 
use Carp;
use strict; 

my $group = $ARGV[0];

open O,$group || croak "cannot open $group:$!\n"; 
while(<O>){
chomp; 
	if (/^#/){
		next;
	}	
	else {
		my @line = split /\t/;
		my $groupName = $line[0]; 
		shift @line;

		my ($taph,$pezi,$basi,$sach,$early) = '';
		
			my $current = $_;
			if ($current =~ m/(NIRR|SPOM|SCOMP)/){$taph = 'OK';} # should at least one Pezizo
			if ($current =~ m/(ANID|NCRA|PCON|Sclsc1|BAUCO|ARTOA|LEPMJ|MACPH|MALGO|MYCGM|USTV1)/){$pezi = 'OK';}
			if ($current =~ m/(CCIN|LACBI|PGRA|Scommune|UMAY)/){$basi = 'OK';}
			if ($current =~ m/(SCER|DEBHA)/){$sach = 'OK';}
			if ($current =~ m/(Bd|AMAG|MUCC1|Rhior3)/){$early = 'OK';}
			
			no warnings;
			if ($taph eq 'OK' && $pezi eq 'OK' && $basi eq 'OK' && $sach eq 'OK' && $early eq 'OK'){
				say $groupName;
			}
	}
}
close O;
