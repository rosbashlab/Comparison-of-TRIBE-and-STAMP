# Comparison-of-TRIBE-and-STAMP

Custom scripts used in the manuscript: Comparison of TRIBE and STAMP for identifying targets of RNA binding proteins in human and Drosophila cells

1) RNA sequencing data was trimmed and aligned using cutadapt and STAR.  The resulting bam files are then converted into bigwig files for viewing, and gene expression is quantified using HTseq.scripts.count and stringtie.
    A. trim_and_align_PE_dm6_2023.sh (Drosophila)
    B. trim_and_align_PE_hg38_2023.sh (Human)

2) One of the outputs from the trim_and_align scripts 
