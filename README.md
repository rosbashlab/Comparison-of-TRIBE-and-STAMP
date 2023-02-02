Comparison-of-TRIBE-and-STAMP in HEK-293 cells and Drosophila S2 cells

Custom scripts used in the manuscript: Comparison of TRIBE and STAMP for identifying targets of RNA binding proteins in human and Drosophila cells

1) RNA sequencing data was trimmed and aligned using cutadapt and STAR.  The resulting bam files are then converted into bigwig files for viewing, and gene expression is quantified using HTseq.scripts.count and stringtie.
    A. trim_and_align_PE_dm6_2023.sh (Drosophila)
    B. trim_and_align_PE_hg38_2023.sh (Human)

2) The sam file that results from the trim and align scripts is used as input to load the mapped data into a mysql database using the script load_table.sh.  This script is described in detail in rosbashlab/Hyper-TRIBE/CODE.

3) Editing sites are identified from mysql table as described in rosbashlab/Hyper-TRIBE/CODE.  specific scripts used here are included.
