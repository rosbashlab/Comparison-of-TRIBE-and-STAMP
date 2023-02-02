Comparison-of-TRIBE-and-STAMP in HEK-293 cells and Drosophila S2 cells

Custom scripts used in the manuscript: Comparison of TRIBE and STAMP for identifying targets of RNA binding proteins in human and Drosophila cells

1) RNA sequencing data was trimmed and aligned using cutadapt and STAR.  The resulting bam files are then converted into bigwig files for viewing, and gene expression is quantified using HTseq.scripts.count and stringtie.
    A. trim_and_align_PE_dm6_2023.sh (Drosophila)
    B. trim_and_align_PE_hg38_2023.sh (Human)

2) The sam file that results from the trim and align scripts is used as input to load the mapped data into a mysql database using the script load_table.sh.  This script is described in detail in rosbashlab/Hyper-TRIBE/CODE.

3) Editing sites are identified from mysql table as described in rosbashlab/Hyper-TRIBE/CODE.  Editing sites were thresholded to 6% editing by editing variables in Threshold_editsites_20_reads.py (see rosbashlab/Hyper-TRIBE/CODE)

4) Editing sites with >1% editing in ADAR only and APOBEC only controls were identified using Threshold_editsites_20_reads.py (see rosbashlab/Hyper-TRIBE/CODE) modified with a 1% cutoff. 

5) Editing sites consistent between two replicates were identified using bedtools in the following shell scripts:
    a. editing_site_overlap_TRIBE.sh
    b. editing_site_closest_STAMP.sh

6) Editing sites identified with greater than 1% editing in enzyme only controls were removed using bedtools and additional output files with coordinates expanded by different amounts were generated.
    a. subtract_slop_enzyme_only_sites_dm6.sh
    b. substract_slop_enzyme_only_sites_hg38.sh
    
    
7) Location of the editing sites in the transcripts were determined using bedtools in the following shell scripts.  Annotation files describing 5'-UTR, 3'-UTR and CDS were downloaded from UCSC genome browser table.
    a. dm6_location.sh
    b. hg38_location.sh
    
8) EdgeR was used to look for perturbations in the transcriptomes of mammalian cells expressing TDP43-TRIBE or TDP43-STAMP.  
    a. DE_HEK_edgeR_TDP43_APOv1.txt 
    b. DE_HEK_edgeR_TDP43_ADARv1.txt 
    
9) Near neighbor preferences were examined by extracting the bases on either side of the editing site and counting the prevalence of each neighboring base.  The script extract_bases_near_editsites_from_bedgraph.pl is contained within the script count_base.sh.  This requires both an annotation file in bed format and a fasta file of the genome.


    
