#!/bin/sh

prefix=${1%.bed*}
#prefix=${1%.bedgraph*}

bedfile=$1
#genomefile=$RHOME"/GENOMES/dmel.fa"
genomefile="/Users/kate/scripts/hg38.p13.fa"

#the location of the annotation file is hard coded in the perl script
#perl /home/analysis/editing/extract_bases_near_editsites_aoife_editbed.pl -b $bedfile -g $genomefile > $prefix".count"


#option 1:
#From from bedgraph file where strand info is not present
#perl /home/analysis/editing/extract_bases_near_editsites_from_bedgraph.pl -b $bedfile -g $genomefile > $prefix".count"

#option 2:
#from bed file where strand info is present
perl /Users/kate/scripts/extract_bases_near_editsites_from_bedgraph.pl -b $bedfile -g $genomefile > $prefix".count"
