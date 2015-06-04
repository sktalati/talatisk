########################################################################################################################################################
##Title: AIBiotech Pre-Assesment Question 2 Binning 
##Author: Snehal K. Talati
##Program Description: This program allows the user to read a FASTA file through command line. It reads through each sequence in the file and determines
##the length of each sequence. It creates a table that shows frequency distribution of lengths of all the sequences in the file. 
##Run Program: perl [fasta_file][output_file] 
##
##
#######################################################################################################################################################
use strict;
use warnings;

###_________________Command Line and File Handling ________________________###
my $file = shift;  		
my $output = shift;
if(!defined($output)){
        die "USAGE Instructions: need input and output files\n";
}
open (OFH, ">$output") or die "Cannot open output file $!\n";

###_______________________ Variable Declaration ________________________###
my $returnedIndex;
my %sequenceHash;
my $length;
my %Length_Hash;
my @lengthArray;

###_______________________ Main Method__________________________________###
$returnedIndex = parseFASTA($file);
%sequenceHash = %$returnedIndex;

my $Length_HashRef = createHash2();
%Length_Hash = %$Length_HashRef;

foreach my $key (keys %sequenceHash){
	$length = lengthSEQ($sequenceHash{$key});	#calculates the length for each sequence using the length subroutine
	#depending on the length of the sequence, it will be placed into it's respective bin
	#for example, if the length is 25 or less than 25, it will be placed in the '25' bin and so on
	if ($length > 0 && $length <=25){
			$Length_Hash{'25'}++;
		}
		elsif ($length > 25 && $length <=50){
			$Length_Hash{'50'}++;
		}
		elsif ($length > 50 && $length <=75){
			$Length_Hash{'75'}++;
		}
		elsif ($length > 75 && $length <=100){
			$Length_Hash{'100'}++;
		}
		elsif ($length > 100 && $length <= 1000){
			$Length_Hash{'1000'}++;
		}
		elsif ($length > 1000){
			$Length_Hash{'10000'}++;
		}
} ## end of foreach loop

###________________________Printing to Outfile______________________###
print OFH "Bin\tLength Bin\n";	#header of the output file
foreach my $keys1 (sort {$a <=> $b} keys %Length_Hash){
	if($keys1 =~ '25'){
		print OFH "<25\t$Length_Hash{$keys1}\n";
	}
	elsif ($keys1 eq '50'){
		print OFH "26-50\t$Length_Hash{$keys1}\n";
	}
	elsif ($keys1 eq '75') {
		print OFH "51-75\t$Length_Hash{$keys1}\n";
	}
	elsif ($keys1 eq '100') {
		print OFH "76-100\t$Length_Hash{$keys1}\n";
	}
	elsif ($keys1 eq '1000') {
		print OFH "101-1000\t$Length_Hash{$keys1}\n";
	}
	elsif ($keys1 eq '10000') {
		print OFH "More than 1000\t$Length_Hash{$keys1}\n"; ## here the value is made clear that 10,000 refers to lengths > 1000
	}
} ## end of foreach loop


###_______________________ Sub routines _________________________________###
## Parse FASTA sub routine
#Parses through the FASTA file and stores the header as the key and the sequence as the value in a hash.

sub parseFASTA{
my ($file) = @_;
###########################  open Files #############################
open (IFH, "$file") or die "Cannot open input file$!\n";

######################## Variable declarations #######################
my $line;
my $header;
my $sequence ="";
my $flag=0;
my $index;
my %returnedHash;

while($line = <IFH> ) {
        chomp $line;        
        if($line =~/^>/){
                if($flag !=0){						
							$returnedHash{$header} = $sequence;						                       
							$header = $line;
							$sequence ="";					
                } #end inner if
                else{
                        $header = $line;
                        $sequence ="";
                        $flag++;
                }
        }#end outer if condition        
        else{
                $sequence .= $line;
        }   #end else condition
}# close while

$returnedHash{$header} = $sequence;	

return \%returnedHash;
} #end sub paraseFASTA

###______________________________________________________________###
## Length Subroutine
#Finds the length a sequence
sub lengthSEQ{
my ($input) = @_;
my $len;
$len = length($input);   ##finds the length of the inputed sequence
return $len;
}## end of length subroutine

###________________________________________________________________###
## Create Hash Subroutine
#Creates bins to store the distributed lengths
sub createHash2{
my(%Length_Hash) = (
'25' => '0', #bin 0-25
'50' => '0', #bin 26-50
'75' => '0', #bin 51-75
'100' => '0', #bin 76-100
'1000' => '0', #bin 101-1000
'10000' => '0', #bin 1000+ this bin is 'named' 10,000 so it can be sorted when printing
);
return \%Length_Hash;
} ## end of CreateHash subroutine

