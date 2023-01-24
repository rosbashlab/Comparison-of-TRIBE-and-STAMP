#!/bin/sh

#----- Update the following varibles
PERLCODE="/home/analysis/perl_code"
SCRIPTDIR="/home/analysis/scripts"
genome_fai_file="/home/analysis/genome/dm6/genome.fa.fai"
gtf_file="/home/analysis/genome/dm6/refseq_2021/dm6.ncbiRefSeq.gtf"
star_indices="/home/analysis/genome/dm6/star_indices_2.7.8"
#PICARD_JAR="/opt/PICARD/2.8.2/picard.jar"
PICARD_JAR="/opt/PICARD/2.25.0/picard.jar"
#---------End Update variable------------

infile1=$1
infile2=$2
#prefix=${1%*.fastq*}
prefix=$3

#cutadapt -q 20 --trim-n --minimum-length=20 -o $quality_out $input
# trim low quality bases only from 3 prime end, trim Ns, and remove reads below length 12

file1=$prefix".1.fastq"
file2=$prefix".2.fastq"

cutadapt -q 20 --trim-n --minimum-length=10 -o $file1 -p $file2 $infile1 $infile2

file1=$prefix".1.fastq"
file2=$prefix".2.fastq"


##for PE library extract umi from reads before they are mapped 
##-------
#umi_tools extract --bc-pattern=NNNNNNNNN --bc-pattern2=NNNNNNNNN -I $file1 --stdout=$prefix"_processed.1.fastq" --read2-in=$file2 --read2-out=$prefix"_processed.2.fastq"
#
#rm $file1 $file2
#
#-------------------------------
#map the reads with STAR

STAR  --runThreadN 8 --outFilterMismatchNoverLmax 0.06 --outFileNamePrefix $prefix"_" --outFilterMatchNmin 15 --outFilterMultimapNmax 1  --genomeDir $star_indices --outSJfilterReads Unique --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --alignMatesGapMax 25000 --readFilesIn $file1 $file2
#$prefix"_processed.1.fastq" $prefix"_processed.2.fastq"

# --outFilterMismatchNoverLmax 0.06: number of mismatches is <= 6% of mapped read length
# --outFilterMatchNmin 15: min numberof bases mapped genome per read
# --outFilterMultimapNmax 1: output reads that only map to one loci
# --outSJfilterReads Unique : Uniquely mapped reads
# --outSAMstrandField intronmotif : generates an XS attribute for all spliced introns so that it is compatible with cufflinks
# --outFilterIntronMotifs RemoveNoncanonical: also recommended for cufflinks to remove non-canonical junctions

output=$prefix".sam"
mv $prefix"_"Aligned.out.sam $output
#----------
samtools view -@ 4 -Sh -q 10 $output > $prefix"_highquality.sam"
#mv $prefix"_highquality.sam" $output
#-------------
#delete the trimmed PE files
rm $file1 $file2

# create bam file and then sort it
bam_out=$prefix".bam"
samtools view -@ 6 -bhS $output > $bam_out
# keep the sam for record keeping
#rm $output
# create sorted bam file
sort_out=$prefix".sort.bam"
samtools sort -@ 6 $bam_out -o $sort_out
samtools index $sort_out
rm $bam_out

#run Picard to remove duplicates
input_for_picard=$sort_out
dupremove_bam=$prefix"_nodup.bam"
#java -Xmx4g -jar $PICARD_JAR MarkDuplicates INPUT=$input_for_picard OUTPUT=$dupremove_bam METRICS_FILE=dup.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true TMP_DIR=tmp ASSUME_SORTED=true
#updated command line for new version of PICARD 2-2021
java -Xmx4g -jar $PICARD_JAR MarkDuplicates --INPUT $input_for_picard --OUTPUT $dupremove_bam --METRICS_FILE dup.txt --VALIDATION_STRINGENCY LENIENT --REMOVE_DUPLICATES true --TMP_DIR tmp --ASSUME_SORTED true
#rm $input_for_picard

# sort the output bam file from picard
sort_out=$prefix".sort.bam"
samtools sort -@ 6 $dupremove_bam -o $sort_out
samtools index $sort_out
#rm $dupremove_bam


#create the bw file for the alignment, this step is optional for HyperTRIBE pipeline
$SCRIPTDIR/Generate_normalized_bw_from_bam.sh $sort_out $genome_fai_file

#------------
# count reads in genes. -r pos parameter is important for PE libraries, when input bam file is sorted by coordinate
# change the standed parameter if you have a strand specific library
#python -m HTSeq.scripts.count -q -r pos -f bam $sort_out --stranded=no --minaqual=10 $gtf_file > $prefix"_unique_raw.txt"
#note updated command line for newest version.  minaqual default is 10 in versions greater  than 0.5.4
python -m HTSeq.scripts.count -q -r pos -f bam $sort_out --stranded=no $gtf_file > $prefix"_unique_raw.txt"

#count number of mapped reads in bam file
readnum=$(samtools view -c $sort_out)

perl $PERLCODE/gene_expressions_from_raw_reads_dm6.pl -r $readnum $prefix"_unique_raw.txt" > $prefix"_expressions.xls"

  
#-------------------------------------------------- 
#perl $PERLCODE/gene_expressions_from_raw_reads_to_bed_dm6.pl -r $readnum $prefix"_unique_raw.txt" > $prefix"_expressions.bed"

#---------------- Finally run stringtie ------------
assembled_transcript=$prefix"_stringtie_assembled_transcript.txt"
stringtie -A $prefix"_gene_abundance.txt" -o $assembled_transcript -p 6 -e -G $gtf_file $sort_out
#
gzip $assembled_transcript
