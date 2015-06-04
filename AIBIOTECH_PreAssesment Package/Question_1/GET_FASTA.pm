###############################################################################################################################
##Title: AIBiotech Pre_Assesment Question 1 Module File
##Author: Snehal K. Talati 
##Version: 1.0
##Description: This is a Perl Module that is made to obtain fasta files 
##from a directory given a command line arguments of start directory and the 
##number of directories user would like to search for
##Note: Please put this module file in the same directory as the tester.pl file
###############################################################################################################################


package GET_FASTA; ## package definition
use warnings;
use strict;
use Exporter qw(import);

our @EXPORT_OK = qw(get_fasta_files);
our @EXPORT = qw($number);

##__________________________Sub_Routines___________________________________##
sub get_fasta_files{
  my ($dir, $numb, $lev) = @_; ## takes in as parameters the root level which is preset to 0, user preference search level, and starting directory
  my @fasta_array; ## initialization of an array to hold all fastafiles
  opendir(DIR,$dir); ## this statement here opens the directory that is defined by the user
  my @files = readdir(DIR); ## here we initialize an array @files and use perl's built in function ro read in the contents of the directory into the array
  closedir(DIR); ## close the directory after the above processing
  @files = sort(@files); ## sorting the array 
  shift(@files); ## shifts the first value of the array and moves everything down by one
  shift(@files); ## shifts the first value of the array and moves everything down again these are the . and .. directories which are taken out of the array
  ## This foreach loop loops through all the files in the files array
  foreach my $file ( sort @files){
	## This if statement checks to see if the $file in array is a file which is represented by "$dir/$file and $file ends in .fa or .fasta push the file into 
	## the fasta array
	if (-f "$dir/$file" && $file =~ /\.fa$/i || $file =~ /\.fasta/i) {
			push @fasta_array, $file;
	} ## end of if file -f loop
	
    return if ($numb < $lev);## we return the value if the user inputted level which is the $numb < $lev which is the level it is currently at
	## most likely at this point the level should be 0 which is the root/start directory that the user has passed as command line arguments
	## This next if statement checks to see if the "$dir/$file" is a directory if it evaluates as true then again we return the value if the 
	## the $numb < $lev if it is not we move on to the next statement
	if(-d "$dir/$file"){
		return if ($numb < $lev);
		#print "Subdirectory Level Checked: $lev\n"; ## This can be uncommented to check to see if we at the correct level 
        push @fasta_array, get_fasta_files("$dir/$file",$numb,$lev+1); ## if the above return statement is not true we use recursion and call the subroutine
		## again until the above statement evaluates to true while this recursion takes place it is appended or pushed to our @fasta_array
    } ## end of if directory  -d statement 
	
  } ## end of foreach loop
	return @fasta_array; ## return statemnet of the array
} ## end of subroutine get_fasta_files 
1;