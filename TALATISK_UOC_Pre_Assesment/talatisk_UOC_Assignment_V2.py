""" 
Author : Snehal K. Talati
Assignment : Bioinformatician University of Chicago Pre-Assessment
Date Submitted : 6/1/2015

"""

from __future__ import division ## import statement for proper division
import argparse ## importing module argparse
import math

##creating parser object, to provide description of the object
parser = argparse.ArgumentParser(description="This program parses a fastq file to output a flat file which is tab delimited that gives the cycle number, average quality score, and the standard deviation")

#add arguments
parser.add_argument('input_file', type=file, help="FASTQ_File")
parser.add_argument('out_file', type=argparse.FileType('w'), help="results.txt")

## get arguments from the command line
args = parser.parse_args()

## Global Variables
start_position = 1
quality_read_hash = {}
number_of_reads = 0
average_quality = 0.0
stdev_Array = []
std_Hash = {}


for line in args.input_file:
    header = line
    seq = args.input_file.next().rstrip()
    plus = args.input_file.next()
    quality = args.input_file.next().rstrip()

	## This if loop is to obtain a the total number of reads in this case 250
    if plus == "+\n":
        number_of_reads += 1

## This while loop goes through the quality sequence starting from position 1 to the length
## which is 151 and takes the ascii value and converts to decimal value and obtains the read quality
## score. Once the scores are calculated a Hash/Dictionary is used to store the start position as key which is 
## the cycle number with the values of each score for that cycle in a list. Later this key/list(values) pair is used
## to calculate the standard deviation. The second hash/dictionary was used to calculate the sum of all the quality scores
## for each particular cycle/start position which was later used to calculate the average quality score. 
    
    while start_position <= len(quality):
        read_quality = (ord(quality[start_position - 1]) - 33)
        
        ## These if else loops mimic an if/exist loop similiar to PERL 
        ## and check to see if the value exists. If it does, then append. In this case it
        ## appends the list so i.e key: 1 values: [37,38,39...]. If it does not exist, create
        ## the first value
        if start_position in std_Hash:
            std_Hash[start_position].append(read_quality)
        else:
            std_Hash.setdefault(start_position, [])
            std_Hash[start_position].append(read_quality)

		## This if/else loop calculates the total score for each position/cycle. So
		## if it exists then add it to the previous value, if not then create that value.
        if start_position in quality_read_hash:
            quality_read_hash[start_position] += read_quality
        else:
            quality_read_hash[start_position] = read_quality

        start_position += 1

    start_position = 1

## Definitions to calculate the standard deviation if the numpy and scipy module doesn't work
def mean(x):
	return sum(x)*1.0/len(x)

def std(x):
	length = len(x)
	m = mean(x)
	total_sum = 0
	
	for value in x:
		total_sum += (value - m)**2
		
	root = total_sum*1.0/length
	
	return math.sqrt(root)
	
## Printing Results and Calculations

## Print Headers

print >> args.out_file,  "Cycle\tAvg\tStdev"

## This for loop goes through our dictionaries and since the keys for both dictionaries/hashes
## are the same we can use the same for loop to print out results. 
for keys in quality_read_hash:
     quality_sum = quality_read_hash.get(keys) 
     average_quality = quality_sum / number_of_reads
     standard_deviation = std(std_Hash.get(keys))
     print >> args.out_file, "%s\t%0.3f\t%0.3f" % (keys, average_quality, standard_deviation)
     
