###############################################################################################################################################################
## Title: AIBiotech Pre-Assesment Merging 2 Files 
## Author: Snehal K. Talati
## Program Number 3
## Program Description: This program compares two files. It looks through the gene names in one file and finds SNP related information about those gene names
## in the second file. The output file is a tab delimited file that contains rs ID, Gene Name, Ref nucleotide, Alternate nucleotide and the associated diseases.
## Run Program: perl [list_gene_file][clinical_data.vcf file][output file]
##
################################################################################################################################################################
use strict;
use warnings;

#### variable declarations
my %reference_hash;
my $refIndex;
my %data_hash;
my $dataIndex;
my @refArray;
my $RS_ID;
my $merge_refID;
my %combined_hash;
#### subroutine prototypes
sub reference_file_hash ($);
sub data_file_hash($);
sub ref_id_array ($);
sub merge_Hash($$$);
sub process_data ($);
############################ Command Line Instructions #############
my $file = shift;
my $file2 = shift;
my $output = shift;
if(!defined($output)){						##if the third parameter in the command line is not the output, it will print out an error message and die. 
        die "USAGE Instructions: need gene_list_file, datafile, and output file\n";
}
open (OFH, ">$output") or die "Cannot open output file $!\n";
############################ Main Method ######################
$refIndex = reference_file_hash($file);
%reference_hash = %$refIndex;
$dataIndex = data_file_hash($file2);
%data_hash = %$dataIndex;
$RS_ID = ref_id_array($file2);
$merge_refID = merge_Hash($refIndex, $dataIndex, $RS_ID);
@refArray = @$RS_ID;
%combined_hash = %$merge_refID;
process_data($merge_refID);


########################### Subroutines #######################
## reference_file_hash subroutine
## In this subroutine we go through the gene list file and assign the key as the gene name which here is refered to as the $referenceID
## The values however are abitrarily assigned it can be anything I assigned it a a value of 1. 

###_______________________________ReferenceFile Subroutine____________________________###
sub reference_file_hash ($){
my ($file) =@_;
open (IFH, "$file") or die "Cannot open input file$! in createHash\n";
my $line;
my %referenceHash;
my $referenceID;
while($line = <IFH>){			
	chomp $line;
	$referenceID = $line;		
	if (exists $referenceHash{$referenceID}){
		$referenceHash{$referenceID} = 1;
		}
	else{
		$referenceHash{$referenceID}= 1;
		}
	}
return \%referenceHash;	
} ## end of reference_file_hash


###____________________________________Data_File_Hash(VCF File) Subroutine___________________________________###
## data_file_hash subroutine
sub data_file_hash($){
my ($file2) =@_;
open (IFH, "$file2") or die "Cannot open input file$! in createHash\n";
my $line;
my %dataHash;
my $data;
my $header_line;
my $gene_name;
my $ref_id;
while($line = <IFH>){			##Reading through the second file (clinvar data file)
	chomp $line;
	next if ($line =~ /^##/);		##go to the next line if the line starts with '##' 
	if ($line =~ /^#/) {			##if the line starts with '#', set that as the header line
		$header_line = $line;
	}
	else {
		if ($line =~/GENEINFO=/) {		##if the line doesn't start with '#' and if line contains GENEINFO= proceed with the further processing
		($gene_name) = $line =~ /GENEINFO=(\w+)/;	##extract out the gene name
		($ref_id) = $line =~ /RS=(\d+)/;			##extract out the ID
		## This if exists statement is there to populate the dataHash since the values need to be unique we create a 2d hash to make sure the key is unique
		## if it exists the value is equal to the line if it doesn't it creates the 2d hash and assigns line as the value
		if (exists $dataHash{$gene_name}{$ref_id}){	
		$dataHash{$gene_name}{$ref_id} = $line;
		}
		else{
		$dataHash{$gene_name}{$ref_id}= $line;
		} ## end of if exists
		} ## end of outer if statement
	} ## end of else statement	
 } ## end of while loop
 return \%dataHash;	
} ## end of data file_hash subroutine


####_______________________________________Reference IDs Subroutine _____________________________________###
## This subroutine is there so we can obain an array for all the referenceID's so later on we can use that in the dataHash to 
## merge and find the snp we are looking for
## ref_id_array subroutine
sub ref_id_array ($) {
my ($file2) =@_;
open (IFH, "$file2") or die "Cannot open input file$! in createHash\n";
my $line;
my $data;
my $header_line;
my $gene_name;
my $ref_id;
my @RS_IDS;
	while($line = <IFH>){	##while going through the second file (clinvar data file) 
		chomp $line;
		next if ($line =~ /^##/);	##go to the next line if the line starts with '##'
		if ($line =~ /^#/) {		##if the line starts with '#', set that as the header line
			$header_line = $line;
		}
		else {						##if the line doesn't start with '#'
			($ref_id) = $line =~ /RS=(\d+)/;	##extract out the ref id 
			push @RS_IDS, $ref_id;				##push the ref id in the RS_IDS array
			}	
	} #end while loop
 return \@RS_IDS;	
} #end ref_id_array subroutine

################################################### INTERSECT FILES SUBROUTINE #######################################
## merge_Hash subroutine
## In this subroutine the mergeHash is created using all the above subroutines where we obtain the reference hash, datahash, and array/list of reference IDs
sub merge_Hash ($$$) {
my ($ref_id, $data_id, $RSID) = @_;
my %refHash = %$ref_id;
my %dataHash = %$data_id;
my @RS_array = @$RSID;
my %mergeHash;
## In this foreach loop we go through all the RSIDS in the list and foreach RSID in list we go through the keys in in referenceHASH which is the geneName 
## Once we have that we look to see if the reference gene which is the gene we are searching and the RSN which is the ID exists in the dataHash then we create
## the mergeHash where the keys are concatenated to make it unique and we set the value equal to the line which is the value of our dataHash and now we have all
## the information needed to process and print the desired information
	foreach my $RSN (@RS_array) {
		foreach my $reference_genes (keys %refHash) {
			if (exists $dataHash{$reference_genes}{$RSN}) {
				$mergeHash{$reference_genes.$RSN} = $dataHash{$reference_genes}{$RSN};
			}
		} #end inner foreach loop
	} #end outer foreach loop
return \%mergeHash;
} #end merge_Hash subroutine

###__________________________________________________Processing and Printing Subroutine_____________________________________###
## process_data subroutine
sub process_data ($) {
my ($merge_ID) = @_;
my %hashMerge = %$merge_ID;
my @information_array;
my ($line, $dbSNPID, $geneName, $reference, $alternate, $diseases);
print OFH "dbSNP ID\tGene Name\tRef Nucleotide\tAlternate nucleotide\tAssociated Disease\n";
	foreach my $key (keys %hashMerge) {
		$line = $hashMerge{$key};
		($dbSNPID) = $line =~ /RS=(\d+)/;
		($geneName) = $line =~ /GENEINFO=(\w+)/;
		($reference) = $line =~ /rs\d+\s(\w+)/; 
		($alternate) = $line =~ /rs\d+\s\w\s(\S+)\s/;
		$alternate =~ s/\,/\n\t\t\t\t\t\t/; ## This statement is to take care of the nucleotides separated by the comma 
		if ($line =~ /CLNDBN=/) {
			($diseases) = $line =~ /CLNDBN=(.*)\;CLNACC/;
			$diseases =~ s/\|/\,/; ## this is to replace all the '|' characters with commas 
			$diseases =~ s/\\x2c_/\,/g; ## noticed that there were multiple diseases after this segment so replaced this segment with a comma as well
		}
		print OFH "$dbSNPID\t$geneName\t$reference\t$alternate\t$diseases\n"; ## Print obtained information in a tab delimited output file
	} #end foreach loop
} #end process_data subroutine