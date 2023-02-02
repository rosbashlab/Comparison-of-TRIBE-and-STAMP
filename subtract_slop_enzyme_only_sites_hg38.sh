#script to subtract enzyme only sites from experimental editing site lists
#want to maintain gene information if you can
#usage ./subtract_enzyme_only_sites.sh "$final_name"_closest.100_allsites.bed""  
#input is file #11from editing_site_closestx2_TRIBE.sh

infile1=$1
enzyme_only=$2
final_name=$3

#pull prefixes from files for naming

prefix1=${1%*.bed*}
prefix2=${2%*.bed*}


#use Bedtools intersect to identify sites in experimental but not in control

bedtools intersect -a $infile1 -b $enzyme_only -wa -v -f 0.9 > "$final_name"_12_not_in_enzyme.bed""
total_overlap= wc -l  "$final_name"_12_not_in_enzyme.bed""
sort  "$final_name"_12_not_in_enzyme.bed"" | uniq >  "$final_name"_13_not_in_enzyme.unique.bed""
total_overlap1= wc -l  "$final_name"_13_not_in_enzyme.unique.bed""

#summarize remaining sites

perl /Users/kate/scripts/summarize_results.pl "$final_name"_12_not_in_enzyme.bed"" > "$final_name"_14_enzyme_sub_summary.xls""
total_genes= wc -l  "$final_name"_14_enzyme_sub_summary.xls""

#generate bed files with different windows for overlap and meme analysis

#make new files of just editing coordinates in bed format
cut -f 1,2,3  "$final_name"_13_not_in_enzyme.unique.bed"" >  $final_name"_coords_13_not_in_enzyme.bedgraph"
sort  $final_name"_coords_13_not_in_enzyme.bedgraph" | uniq > $final_name"_coords_13_not_in_enzyme_unique.bedgraph"

#Slop with 25bp added on--check to make sure intervals are at least 10 as MEME will crash if short.
bedtools slop -i $final_name"_coords_13_not_in_enzyme_unique.bedgraph" -l 25 -r 25  -g /Users/kate/scripts/hg38_chr.bed > $final_name"_sub_1percent_13_25slop.bed"
awk 'NR==1 ||  (NR>1 && ($3 - $2 > 10))' $final_name"_sub_1percent_13_25slop.bed" > $final_name"_25slop.check.bed"


#slop with 50bp added on
bedtools slop -i $final_name"_coords_13_not_in_enzyme_unique.bedgraph" -l 50 -r 50  -g /Users/kate/scripts/hg38_chr.bed > $final_name"_sub_1percent_13_50slop.bed"
awk 'NR==1 ||  (NR>1 && ($3 - $2 > 10))' $final_name"_sub_1percent_13_50slop.bed" > $final_name"_50slop.check.bed"

#slop with 100bp added on
bedtools slop -i $final_name"_coords_13_not_in_enzyme_unique.bedgraph" -l 100 -r 100  -g /Users/kate/scripts/hg38_chr.bed > $final_name"_sub_1percent_13_100slop.bed"
awk 'NR==1 ||  (NR>1 && ($3 - $2 > 10))' $final_name"_sub_1percent_13_100slop.bed" > $final_name"_100slop.check.bed"

#slop with 10bp added on
bedtools slop -i $final_name"_coords_13_not_in_enzyme_unique.bedgraph" -l 10 -r 10  -g /Users/kate/scripts/hg38_chr.bed > $final_name"_sub_1percent_13_10slop.bed"
awk 'NR==1 ||  (NR>1 && ($3 - $2 > 10))' $final_name"_sub_1percent_13_10slop.bed" > $final_name"_10slop.check.bed"
