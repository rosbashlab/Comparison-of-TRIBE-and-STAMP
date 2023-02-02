#this does not work!!!!!!!


# script to show the distribution of editing sites in various parts of the mRNA
# utilizes bed files listing the coordinates of cds, 3]-UTR, 5-UTR etc.  in /Users/kate/scripts

#input is final bedgraph file listing all those editing sites in experimental that are not in control (output of subtract_enzyme_only_sites.sh)
infile1=$1
prefix1=${1%*.bedgraph*}
#overlap final bed file with each of the components of the mRNA

bedtools intersect -a $infile1 -b /Users/kate/scripts/dm6_refseq_3utr.bed -f 0.9 > "$prefix1"_3utr.bed""
bedtools intersect -a $infile1 -b /Users/kate/scripts/dm6_refseq_5utr.bed -f 0.9 > "$prefix1"_5utr.bed""
bedtools intersect -a $infile1 -b /Users/kate/scripts/dm6_refseq_cds.bed -f 0.9 > "$prefix1"_cds.bed""

three_utr_sites= wc -l  "$prefix1"_3utr.bed"" 
#three_utr_sites= sed -n '$=' "$prefix1"_3utr.bed""
#echo $three_utr_sites
five_utr_sites= wc -l "$prefix1"_5utr.bed""
#five_utr_sites= sed -n '$=' "$prefix1"_5utr.bed""
cds_sites= wc -l  "$prefix1"_cds.bed""
#cds_sites= sed -n '$=' "$prefix1"_cds.bed""
#echo $cds_sites

#total=$(three_utr_sites + five_utr_sites + cds_sites)
#echo $total
#five= 'expr $five_utr_sites / $total'
#echo $five
#three= (expr ($three_utr_sites / $total))
#echo $three"=3'UTR"
#cds=(expr ($cds_utr_sites / $total))
#echo $cds


