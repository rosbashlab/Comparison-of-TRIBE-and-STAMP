#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my ($genome_file, $bed_file);

my %option;
#getopts( 'g:c:l:h', \%option );
getopts( 'g:b:h', \%option );
if (( $option{g} ) && ( $option{b} ))  {
    $genome_file = $option{g};
    $bed_file = $option{b};
}

my ($g_hash) = &process_fastafile($genome_file);

my $annotation_file = "/Users/kate/scripts/hg38_annotation.bed";
my ($strand_hash) = &getGeneStrand($annotation_file);

#foreach my $gene (keys %$strand_hash) {
#    print STDERR "key: |$gene|; strand:|$strand_hash->{$gene}|\n";#
#
#    die;
#}

my $arr2d=[];
open(my $BEDFILE, "<", $bed_file) 
        or die "unable to open ct file $bed_file";
while ( my $line = <$BEDFILE> ) {
    chomp $line;
    next if ($line=~/^[\n\s]/); #skip lines that beginning with new line
    my @arr = split(/\t/, $line);
    push @{$arr2d}, \@arr;


 
}
close $BEDFILE;

my ($chr, $chr_start, $chr_end);
foreach my $line ( @{$arr2d} ) {
    $chr=$line->[0];
    $chr_start= $line->[1];
    $chr_end=$line->[2];
    my $gene_name = $line->[7];
    $gene_name=~s/\s//g;
    my $strand = $strand_hash->{$gene_name}; 
#    print STDERR "gene_name\t|$gene_name|\t$strand\n";
#    die;
#    my $strand = $strand_hash->{$gene_name};    
    next if ($chr=~/chrUextra/);
    
    my $seq_start = $chr_start;
    my $seq_end =  $chr_end;
    my $seq_length = $seq_end - $seq_start + 1; 
    my $seq_pos = $seq_start-1;
#now retrieve the sequence from the chromosome
    my $chr_seq = $g_hash->{$chr} ;
    my $seq_segment = substr($chr_seq, $seq_pos, $seq_length);
#    $seq_segment = uc($seq_segment);
#now if the strand is negative, make is 5' to 3' by reserve complementing
 my ($str5p_3base, $str5p_2base, $str5p_1base, $str3p_1base, $str3p_2base, $str3p_3base, $all_bases);

    $str5p_3base=substr($chr_seq, ($seq_pos-3), 1);
    $str5p_2base=substr($chr_seq, ($seq_pos-2), 1);
    $str5p_1base=substr($chr_seq, ($seq_pos-1), 1);
    $str3p_1base=substr($chr_seq, ($seq_pos+1), 1);
    $str3p_2base=substr($chr_seq, ($seq_pos+2), 1);
    $str3p_3base=substr($chr_seq, ($seq_pos+3), 1);
    $all_bases=substr($chr_seq, ($seq_pos-3), 7);

    if ($strand eq '-') {
	$seq_segment=&revcomp($seq_segment);

	$str5p_3base=substr($chr_seq, ($seq_pos+3), 1);
	$str5p_3base=&revcomp($str5p_3base);
	$str5p_2base=substr($chr_seq, ($seq_pos+2), 1);
	$str5p_2base=&revcomp($str5p_2base);
	$str5p_1base=substr($chr_seq, ($seq_pos+1), 1);
	$str5p_1base=&revcomp($str5p_1base);

	$str3p_1base=substr($chr_seq, ($seq_pos-1), 1);
	$str3p_1base=&revcomp($str3p_1base);
	$str3p_2base=substr($chr_seq, ($seq_pos-2), 1);
	$str3p_2base=&revcomp($str3p_2base);
	$str3p_3base=substr($chr_seq, ($seq_pos-3), 1);
	$str3p_3base=&revcomp($str3p_3base);

	$all_bases=&revcomp($all_bases);

    }

    
    
    
#    if ($seq_segment eq "T") {
#	#discard those entries for the time being...
#	next;
#    }
    
 #   my $fasta_output = ">$chr:$chr_start-$chr_end:$strand:$seq_length\n$seq_segment\n";

  my $fasta_output = ">$chr:$chr_start-$chr_end:$strand\t$str5p_3base\t$str5p_2base\t$str5p_1base\t$seq_segment\t$str3p_1base\t$str3p_2base\t$str3p_3base\t$all_bases\n";
    
    print "$fasta_output";
#    die;
}





exit;

sub revcomp {
    my ($seq_segment) = @_;
    $seq_segment=~tr/ACGT/TGCA/;
    my $rev_seq = reverse($seq_segment);
    $seq_segment = $rev_seq;
    return $seq_segment;
}


sub process_fastafile {
    my ($fafilename) = @_;
    my ($fa_hash) = {};
    
    my $input_filename = $fafilename;
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open ct file $input_filename";
    
    
    my ($first_part, $second_part) = ("", "");
    while ( my $line = <$INFILE> ) {
        
        if ( $line =~ /^>/) {
            
            unless ( $first_part eq '') {
                $fa_hash->{$first_part} = uc($second_part);
                
                #$seq =~ s/[\n\s\t\r\W]//g; #should I remove other unwanted characters?
                
                ($first_part, $second_part) = ("", "");
            }

            chomp $line;
            # print "header: $line\n"; remove ">"
            my $foo = reverse($line);
            chop($foo);
            $first_part = reverse($foo);
            
        } else {
            # print $line;
	    chomp $line;
            $second_part .= $line; 
        }
    }
    
    $fa_hash->{$first_part} = uc($second_part);    
    return ($fa_hash);    
}




sub getGeneStrand {
    my ($annotation_file) = @_;
    
    my $hash = {};
    open(my $LINE, "<", $annotation_file) 
	or die "unable to open file $annotation_file";
    
    while ( my $line = <$LINE> ) {
	chomp $line;
	
	if ($line=~/geneName/) {
#	    $first_line = $line;
	    next;
	}
	
	my @arr = split(/\t/, $line);
	
	my $gene = $arr[0];
	my $strand = $arr[3];

	$hash->{$gene}=$strand;	
#	print STDERR "$gene $strand";
#	die;
    }
    close $LINE;
    return ($hash); 
}
