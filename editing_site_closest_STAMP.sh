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
sort  $prefix1".edit.bedgraph" | uniq >  $prefix1".2.edit.unique.bedgraph"
sort $prefix2".edit.bedgraph" | uniq > $prefix2".2.edit.unique.bedgraph"

# print number of unique sites in each file
infile1_sites= wc -l  "$infile1"
uniq_infile1_sites= wc -l "$prefix1".2.edit.unique.bedgraph""
infile2_sites= wc -l  "$infile2"
uniq_infile2_sites= wc -l "$prefix2".2.edit.unique.bedgraph""

rm $prefix1".edit.bedgraph"
rm $prefix2".edit.bedgraph"

#sort both input files prior to using bedtools closest
sort -k1,1 -k2,2n  $prefix1".2.edit.unique.bedgraph" > $prefix1".3.edit.unique.sort.bedgraph"
sort -k1,1 -k2,2n $prefix2".2.edit.unique.bedgraph" > $prefix2".3.edit.unique.sort.bedgraph"

#calculate overlap of the two files--this uses only editing site coordinates
bedtools closest -a "$prefix1".3.edit.unique.sort.bedgraph"" -b "$prefix2".3.edit.unique.sort.bedgraph"" -d > "$final_name"_4a_closest.bed""

bedtools closest -a "$prefix2".3.edit.unique.sort.bedgraph""  -b  "$prefix1".3.edit.unique.sort.bedgraph"" -d > "$final_name"_4b_closest.bed""
total_overlapa= wc -l  "$final_name"_4a_closest.bed""
total_overlapb= wc -l  "$final_name"_4b_closest.bed""
rm $prefix1".3.edit.unique.sort.bedgraph" 
rm $prefix2".3.edit.unique.sort.bedgraph"


#write a new file that contains all sites within 100bp in rep1 and rep2
awk '$7 <= 100' "$final_name"_4a_closest.bed"" > "$final_name"_5a_closest.100.bed""
awk '$7 <= 100' "$final_name"_4b_closest.bed"" > "$final_name"_5b_closest.100.bed""
total_overlap= wc -l  "$final_name"_5a_closest.100.bed""
total_overlap= wc -l  "$final_name"_5b_closest.100.bed""

#rebuild list of all editing sites in rep1 and rep2 within 100bp of site in biological replicate
#remove last column with distance between sites--> note that this is for mac0sX as cut --complement doesn't work on osx
gcut  -f 7 --complement "$final_name"_5a_closest.100.bed""  > "$final_name"_6a_closest.100_nodistance.bed"" 
gcut  -f 7 --complement "$final_name"_5b_closest.100.bed""  > "$final_name"_6b_closest.100_nodistance.bed"" 

#remove columns 4-6 from a file and then append these on to the bottom of that file so all sites meeting criteria are in one list.
gcut -f 4-6 "$final_name"_6a_closest.100_nodistance.bed"" > "$final_name"_7a_closest.100_allsites.bed"" 
cut -f 1-3 "$final_name"_6a_closest.100_nodistance.bed"">> "$final_name"_7a_closest.100_allsites.bed"" 


gcut -f 4-6 "$final_name"_6b_closest.100_nodistance.bed"" > "$final_name"_7b_closest.100_allsites.bed"" 
cut -f 1-3 "$final_name"_6b_closest.100_nodistance.bed"">> "$final_name"_7b_closest.100_allsites.bed"" 

# delete intermediate files
rm "$final_name"_6a_closest.100_nodistance.bed"" 
rm "$final_name"_6b_closest.100_nodistance.bed"" 

rm "$final_name"_5a_closest.100.bed"" 
rm "$final_name"_5b_closest.100.bed"" 

#count all sites in both comparison lists.
wc -l  "$final_name"_7a_closest.100_allsites.bed"" 
wc -l  "$final_name"_7b_closest.100_allsites.bed"" 

#identify any sites in a list not in b list.  Important to include all without including everything 2x.  If same site is included from both expt it is in list 2x with different editing %
bedtools intersect -a  "$final_name"_7a_closest.100_allsites.bed"" -b "$final_name"_7b_closest.100_allsites.bed"" -v > "$final_name"_7a_not_in_b.bed"" 
#cut -f 1-3 "$final_name"_7a_not_in_b.bed""  >> "$final_name"_7b_closest.100_allsites.bed"" 

wc -l "$final_name"_7a_not_in_b.bed"" 
wc -l  "$final_name"_7b_closest.100_allsites.bed"" 

#sort  -k1,1 -k2,2n  $final_name"_7b_closest.100_allsites.bed" | uniq >   $final_name"_8_closest.100_uniq_allsites.bed"
#wc -l   $final_name"_8_closest.100_uniq_allsites.bed"

#rebuild bedgraph file for overlapping sites
#first rebuild bedgraph file for unique sites in a list not in b list.
bedtools intersect -a  $final_name"_7a_not_in_b.bed" -b "$infile1" -wb -f 0.9 > "$final_name"_9a_closest.100_allsites.bedgraph""
cut -f 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 "$final_name"_9a_closest.100_allsites.bedgraph"">  "$final_name"_10a_closest.100_allsites.final.bedgraph""

#then build bedgraph file for all sites in b list.
bedtools intersect -a  $final_name"_7b_closest.100_allsites.bed" -b "$infile2"  -wb -f 0.9 > "$final_name"_9b_closest.100_allsites.bedgraph""
cut -f 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 "$final_name"_9b_closest.100_allsites.bedgraph"">  "$final_name"_10b_closest.100_allsites.final.bedgraph""
wc -l  "$final_name"_10b_closest.100_allsites.final.bedgraph""

#cut all sites from a only list and add to end of b list
cut -f 1-24 "$final_name"_10a_closest.100_allsites.final.bedgraph"">> "$final_name"_10b_closest.100_allsites.final.bedgraph""

#rm "$final_name"_9_closest.100_allsites.bedgraph""

wc -l  "$final_name"_10a_closest.100_allsites.final.bedgraph""
wc -l  "$final_name"_10b_closest.100_allsites.final.bedgraph""
sort  "$final_name"_10b_closest.100_allsites.final.bedgraph"" | uniq >  "$final_name"_11_closest.100_uniq_allsites.final.bedgraph""
wc -l  "$final_name"_11_closest.100_uniq_allsites.final.bedgraph""

#summarize results of final bedgraph that represents the sites that are in both of the original bedgraph files.
#perl /Users/kate/scripts/summarize_results.pl "$final_name"_overlap.final.unique.bedgraph"" > "$final_name"_overlap.summary.xls""
#total_genes= wc -l  "$final_name"_overlap.summary.xls""
