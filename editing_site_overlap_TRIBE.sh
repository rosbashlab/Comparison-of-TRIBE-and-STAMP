# Script to overlap two bed files, generate an output file of shared sites and count overlap.
infile1=$1
infile2=$2
final_name=$3


prefix1=${1%*.bedgraph*}
prefix2=${2%*.bedgraph*}

echo $prefix1
echo $prefix2

#make new files of just editing coordinates in bed format
cut -f 1,2,3 $infile1 >  $prefix1".edit.bedgraph"
cut -f 1,2,3 $infile2 >  $prefix2".edit.bedgraph"

#make unique bed files of editing sites
sort  $prefix1".edit.bedgraph" | uniq >  $prefix1".edit.unique.bedgraph"
sort $prefix2".edit.bedgraph" | uniq > $prefix2".edit.unique.bedgraph"

# print number of unique sites in each file
infile1_sites= wc -l  "$infile1"
uniq_infile1_sites= wc -l "$prefix1".edit.unique.bedgraph""

infile2_sites= wc -l  "$infile2"
uniq_infile2_sites= wc -l "$prefix2".edit.unique.bedgraph""

#echo "Number of sites in file 1: $infile1_sites"
#echo "Number of unique sites in file 1: $uniq_infile1_sites"

#calculate overlap of the two files--this uses only editing site coordinates
#cat -t "$prefix1".edit.unique.bed"" > "$prefix1".edit.unique.tab.bed"" 
#cat -t "$prefix2".edit.unique.bed"" > "$prefix2".edit.unique.tab.bed""
bedtools intersect -a "$prefix1".edit.unique.bedgraph"" -b "$prefix2".edit.unique.bedgraph"" -f 0.9 > "$final_name"_overlap.bed""
total_overlap= wc -l  "$final_name"_overlap.bed""

#rebuild bedgraph file for overlapping sites
bedtools intersect -a "$final_name"_overlap.bed"" -b "$infile1"  -wb -f 0.9 > "$final_name"_overlap.bedgraph""
cut -f 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 "$final_name"_overlap.bedgraph"">  "$final_name"_overlap.final.bedgraph""
rm "$final_name"_overlap.bedgraph""
total_overlap_1= wc -l  "$final_name"_overlap.final.bedgraph""
sort  "$final_name"_overlap.final.bedgraph"" | uniq >  "$final_name"_overlap.final.unique.bedgraph""
total_overlap2= wc -l  "$final_name"_overlap.final.unique.bedgraph""

#summarize results of final bedgraph that represents the sites that are in both of the original bedgraph files.
perl /Users/kate/scripts/summarize_results.pl "$final_name"_overlap.final.unique.bedgraph"" > "$final_name"_11_overlap.summary.xls""
total_genes= wc -l  "$final_name"_11_overlap.summary.xls""
