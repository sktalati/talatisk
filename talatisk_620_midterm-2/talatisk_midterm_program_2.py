__author__ = 'Snehal K. Talati'

##import statements
import argparse
import re


parser = argparse.ArgumentParser(description="This program is a program to parse a genebank file"
                                             "for the file there are certain information we are interested"
                                             "in obtaining. The given task is to include in a tab delimited file"
                                             "organism, chromosome, contig, gene_name, strand orientation, and the "
                                             "start/end for each gene in the given file  ")

##add arguments to our parser which are the two files the first is the genebank file and the second is the output file name
parser.add_argument('gen_bank', type=file, help='genbank file')
parser.add_argument('gen_bank_output', type=argparse.FileType('w'), help="output file")
args = parser.parse_args()

## Print the header line to the output file
print >> args.gen_bank_output, "organism\tchromosome\taccession\tgene_name\tstrand\tgstart\tgend"

## For loop to read through each line in our genebank file
for line in args.gen_bank:

    ## First if block is to parse the organism name which in our file is ORGANISM then space and name
    ## The if statement is just a check to see whether or not we have the correct line which follows for
    ## all the if blocks
    if re.search('ORGANISM\s+(.*)', line):
        organism = re.search('ORGANISM\s+(.*)', line).group(1)

    ## This if block is to obtain the chromosome
    if re.search('\/chromosome=\"(\w)\"', line):
        chromosome = re.search('\/chromosome=\"(\w)\"', line).group(1)

    ## This if block is to obtain the contig ID which is found after looking for LOCUS because
    ## before I had accession ID but noticed that some entries had more than one accession IDS(contig ID)
    if re.search('LOCUS\s+(\w+)', line):
        accession = re.search('LOCUS\s+(\w+)', line).group(1)

    ##This if block is to obtain the gene start and gene end for the positive strand
    ## Both cases were accounted for because some entries had <start..>end and some were start..end
    if re.search('\s+gene\s+<?\d+\.\.', line):
        gstart = re.search('\s+gene\s+<?(\d+)', line).group(1)
        gend = re.search('\s+gene\s+<?\d+\.\.>?(\d+)', line).group(1)
        strand = '+'

    ## This if block is to search for the gene name if the above two cases are found
    ## Go immediately to the next line to obtain the gene_name
    if re.search('\s+gene\s+<?\d+\.\.', line):
        line = next(args.gen_bank)
        gene_name = re.search('/gene=\"(.*)\"', line).group(1)

        ## First print statement to print all the information obtained to the output file
        print >> args.gen_bank_output, organism + "\t" + chromosome + "\t" + accession + "\t" + gene_name + "\t" + strand + "\t" + gstart + "\t" + gend

    ## This if block is for the scenario if there is a complement involved then we have to reprocess
    ## our new gene start and end because in this case the first number is our end and the second number is our start
    ## because of the reverse direction/complement
    if re.search('gene\s+complement(.*)', line):
        gcend = re.search('gene\s+complement\(<?(\d+)\.\.>?\d+', line).group(1)
        gcstart = re.search('gene\s+complement\(<?\d+\.\.>?(\d+)', line).group(1)
        strand = '-'

    ##This if block if the statment has complement in that line we are checking
    ## Then we go to the next line and obtain the gene name
    if re.search('gene\s+complement(.*)', line):
        line = next(args.gen_bank)
        cgene_name = re.search('/gene=\"(.*)\"', line).group(1)

        ## Second print statement to print our the entirety of our results
        print >> args.gen_bank_output, organism + "\t" + chromosome + "\t" + accession + "\t" + cgene_name + "\t" + strand + "\t" + gcstart + "\t" + gcend







