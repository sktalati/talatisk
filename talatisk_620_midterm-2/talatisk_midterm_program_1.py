from __future__ import division ## added so division is done correctly
__author__ = 'Snehal K. Talati'
## Import Statements
import argparse
import os
import re


parser = argparse.ArgumentParser(description="This program takes in six arguments from "
                                             "the command line. The first is the file with"
                                             "all the refseqIDs from the mouse. The second"
                                             "file is the query file which is a fasta file for "
                                             "all mouse refseq sequence and the third file is"
                                             "the fasta file for all refseq sequences. The fourth"
                                             "file is the actual blast results written to the file."
                                             "The fifth file is the output from the program results."
                                             "The last argument that is accepted is a user defined"
                                             "threshold from the command line. The program blasts two files"
                                             "and then uses the refseqIDs from the first file to search"
                                             "for the homologs in the blast result ")

##add arguments NOTE: special case used for the blast file wb+ which means we can write and then read from that file
parser.add_argument('ref_seq_file', type=file, help="ref_seqID")
parser.add_argument('query_file', type=file, help="mouse.rna.fna")
parser.add_argument('subject_file', type=file, help="human.rna.fna")
parser.add_argument('blast_output', type=argparse.FileType('wb+'), help="homolog_blast")
parser.add_argument('processed_output', type=argparse.FileType('w'), help="output_results")
parser.add_argument('input_threshold', type=float)
args = parser.parse_args()


## These are the names of the three files
query_file = args.query_file.name
subject_file = args.subject_file.name
blast_file = args.blast_output.name

## Definition of the blast commands to blast the mouse fasta file which is the query file and human fasta file which is our subject
## To make things simpler a blast custom output was used to figure out the fields that were of interest
cmd1 = ("makeblastdb -in " + subject_file + " -dbtype nucl -out humandb.db")
cmd2 = ("blastn -db humandb.db -query "+ query_file +" -outfmt \"6 qseqid sseqid qlen slen length bitscore evalue\"" + " -evalue 1e-05 -out "+ blast_file)

## Actual statements to run the commands through python using the os module
makeblastdb= os.system(cmd1)
blast_results = os.system(cmd2)

## Creating Lists
refseq = []
mouserefseq = []

## This for loop goes through each line in the file of interested refseqIDs
for line in args.ref_seq_file:
    refseqID = line.rstrip() ## each line is stripped of new line and stored as the refseqID
    refseq.append(refseqID) ## once refseq ID is obtained from this file we add that to our refseq list

## This is our second for loop to go through the blast output same is done as the above file
for line2 in args.blast_output:
    lineID = line2.rstrip() ## for each line in this file we strip the line of a new line character and store in lineID
    mouserefseq.append(lineID) ## once lineID is obtained we add that to the mouserefseq list which is our second list


## Print statement to print the header line in out processed_output file
print >> args.processed_output, "queryID\tsubjectID\tquery_length\tsubject_length\talign_length\tbit_score\tevalue\tthreshold"


## Main logic this is a nested for loop structure to go through both lists so for every key in our refseq
## list which is our refseqID for mouse and for every value in our mouserefseq list if that key is in the second list which is called
## value then we do the processing for each value because now the only results at hand are those that match
## from the refseqID list
for key in refseq:
    for value in mouserefseq:
        if key in value:
            value = value.split('\t')
            queryID = re.search('ref\|(.*)\|', value[0]).group(1)
            subjectID = re.search('ref\|(.*)\|', value[1]).group(1)
            query_length = value[2]
            subject_length = value[3]
            align_length = value[4]
            evalue = value[6]
            bit_score = value[5]
            threshold = float(align_length) / float(query_length) ## calculation of the threshold

            ## if condition to check to see if the threshold is greater than or equal to our input threshold print the results
            if threshold >= args.input_threshold:
                print >> args.processed_output, queryID + "\t" + subjectID + "\t" + query_length + "\t" + subject_length + "\t" + align_length + "\t" + bit_score + "\t" + evalue + "\t" + str(threshold)






































