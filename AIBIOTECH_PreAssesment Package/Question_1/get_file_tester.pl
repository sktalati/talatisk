########################################################################################################
##Title: AIBiotech Pre-Assesment Question 1 Tester File
##Author: Snehal K. Talati 
##Version: 1.0
##Description: This is a perl script to serve as the GET_FASTA Module tester if this script compiles properly
##which it does it will allow you to search for the .fa or .fasta files given a start directory and the number 
##of directories in which the user would like search through
########################################################################################################
use strict;
use warnings;
use GET_FASTA; ## statement to use Module

################### sub routine ############################################
my $startdir = shift; ##takes in the path from the command line
my $number = shift; ##takes in the desired number from the command line
## if last statement in command line is not defined die and print the error usage statement
if(!defined($number)) {
        die "USAGE: perl $0 please input directory path and the number of directories you wish to search for\n";
}
my $level = 0; ## constant that should not be changed must remain at 0 as the start directory is our root of the tree
sub get_fasta_files($$$); ## prototype of the subroutine which takes in 3 scalar arguments as parameters

##____________________ Main Method ________________________________________##

## Here an array called filesarray is initialized and assigned the array that is returned from the subroutine in our module
## the special syntax to use your module is accomplished by MODULENAME::NAMEOFSUB(@ars) passed to it the arguments required
my @filesarray = GET_FASTA::get_fasta_files($startdir, $number, $level);

## foreach loop to print all the fasta files in the @filesarray
foreach my $fasta_files (sort {$a cmp $b} @filesarray) {
	print "$fasta_files\n";
}


