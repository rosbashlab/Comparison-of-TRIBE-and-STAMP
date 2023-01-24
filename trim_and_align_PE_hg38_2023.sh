
#!/bin/sh
PERLCODE="/home/analysis/perl_code"
SCRIPTDIR="/home/analysis/scripts"

#----- Update the following varibles
star_indices="/home/analysis/genome/hg38_2021/GenomeDir"
TRIMMOMATIC_JAR="/opt/TRIMMOMATIC/0.36/trimmomatic.jar"
PICARD_JAR="/opt/PICARD/2.25.0/picard.jar"
GENOME_FAI_FILE="/home/analysis/genome/hg38_2021/hg38.fa.fai"
gtf_file="/home/analysis/genome/hg38_2021/hg38.ncbiRefSeq.gtf"
#---------End Update variable------------

# Use the loop below to trim_and_align.sh 
#filelist=`ls *.fastq`#
#for file in ${filelist[@]}
#do

# the input fastq file should have .fastq prefix, for example s2_mRNA.fastq or HyperTRIBE_rep1.fastq

infile1=$1
infile2=$2
prefix=${1%*_R1.fastq}

file1=$prefix".1.fastq"
file2=$prefix".2.fastq"

#remove first 6 bases from first read, due to potential random hexamer priming error
cutadapt -q 20 --trim-n --minimum-length=10 -o $file1 -p $file2 $infile1 $infile2


#-------------------------------
#map the reads with STAR
#star_indices="/home/analysis/genome/dm6/star_indices"

#STAR  --runThreadN 8 --outFilterMismatchNoverLmax 0.06 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 --outFileNamePrefix $prefix"_" --outFilterMatchNmin 15 --outFilterMultimapNmax 1  --genomeDir $star_indices --outSJfilterReads Unique --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --alignMatesGapMax 25000 --readFilesIn $file1 $file2

STAR  --runThreadN 8 --outFilterMismatchNoverLmax 0.06 --outFileNamePrefix $prefix"_" --outFilterMatchNmin 15 --outFilterMultimapNmax 1  --genomeDir $star_indices --outSJfilterReads Unique --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --alignMatesGapMax 25000 --readFilesIn $file1 $file2

gzip $file1 $file2 &

output=$prefix".sam"
mv $prefix"_"Aligned.out.sam $output

#following code is tested with samtools 1.3.1, you might have to tweak it a bit bases your installed verison of samtools (these flags can be problematic for older version of samtools: -@, -o)
#remove low quality alignment
samtools view -@ 4 -Sh -q 10 $output > $prefix"_highquality.sam"
mv $prefix"_highquality.sam" $output
bam_out=$prefix".bam"
#convert sam to bam 
samtools view -@ 4 -bhS $output > $bam_out
rm $output
#sort the bam file before using picard
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

rm $input_for_picard

# sort the output bam file from picard
sort_out=$prefix".sort.bam"
samtools sort -@ 6 $dupremove_bam -o $sort_out
rm $dupremove_bam

# The next step of HyperTRIBE requires the sam file to be sorted 
#Create a SAM file from this sorted bam file
samtools view -@ 4 -h $sort_out > $prefix".sort.sam"
samtools index $sort_out
#------------
echo "Done with STAR mapping and PCR duplicate removal with PICARD"
echo "created sam file: $prefix.sam"
#-------------
## end of do for fastq file
#done
#--------------- Add on code --------

#create the bw file for the alignment, this step is optional for HyperTRIBE pipeline
$SCRIPTDIR/Generate_normalized_bw_from_bam.sh $sort_out $GENOME_FAI_FILE

#------------
# count reads in genes. -r pos parameter is important for PE libraries, when input bam file is sorted by coordinate
# change the standed parameter if you have a strand specific library
python -m HTSeq.scripts.count -q -r pos -f bam $sort_out --stranded=no --minaqual=10 $gtf_file > $prefix"_unique_raw.txt"

#count number of mapped reads in bam file
PE_Reads=$(samtools view -c $sort_out)
readnum=$(($PE_Reads/2))
echo "Read num: $readnum"

#perl $PERLCODE/gene_expressions_from_raw_reads_mm10_chrZ.pl -r $readnum $prefix"_unique_raw.txt" > $prefix"_expressions.xls"
#-------------------------------------------------- 
#perl $PERLCODE/gene_expressions_from_raw_reads_to_bed_mm10_chrZ.pl -r $readnum $prefix"_unique_raw.txt" > $prefix"_expressions.bed"

#---------------- Finally run stringtie ------------
assembled_transcript=$prefix"_stringtie_assembled_transcript.txt"
stringtie -A $prefix"_gene_abundance.txt" -o $assembled_transcript -p 6 -e -G $gtf_file $sort_out
#
gzip $assembled_transcript
