# BLAST-based-Genome-Coordinate-Converter
A tool to convert genome coordinates from one genome version to another.
_______________________________________________________________________________________________________________________________
Use at your own risk. I cannot provide support. All information obtained/inferred with this script is without any implied warranty of fitness for any purpose or use whatsoever.

**ABOUT** 

This program is used to re-map genome coordinates from one genome build to another. To avoid issues associated with nomenclature and coordinates, the program uses sequence alignments.  Sequences are extracted from the original genome via a BED file. Sequences are aligned to the new genome using BLAST (1) and filters are applied to categorize alignments and to choose which alignments likely represent the correct coordinates on the new genome.  The BED files used as input in this program can be generated using the GTF Gene Extractor tool (https://bjtill.github.io/gtf_extractor_V1_1.html). 

**INSTALLATION**

This program was built to work on Linux systems and tested on Ubuntu 22.04. You may potentially get this to work in Mac or on Windows with a bash emulator, but this has not been tested. First, download the BGC_Dependencies .sh file matching the version of the program you are using. From a terminal window, give the script permission to run (chmod +x) and then run (./). This program will test if everything you need to run BLAST-based Genome Coordinate Converter is installed on your system. The program will create a new directory containing the name DependencyTester_BGC with the version and date added. Inside this directory you will find a log file that tells you if the program or command tool was found or if it needs to be installed, along with suggestions on how to install things.

**RUNNING**

Once you have all the dependencies installed, give permission and launch the program from the terminal window (using chmod +x and ./). A graphical window will appear where you can enter the various parameters.


**INPUT FILES**

BED file:

A tab delimited file consisting of chromosome start stop name, where chromosome nomenclature must match the original genome selected. Start and stop are numbers that represent the position of the beginning and end of the gene.  The fourth column is the name.  Typically this is the gene name, but it can be anything so long as a name is used only once in a bed file. Symbols other than _ and spaces should be avoided.  NOTE that the GTF extractor program can be used to generate BED files in the correct format.  It is advised to try this before manually making a BED file.  

Original genome FASTA:

This is the genome from which the input BED file was created. Note that the chromosome names in this file must match the BED file (the same genome build from different sources can have different chromosome names). Using the GTF extractor program avoids this issue.  

New genome FASTA: 

This is the genome you wish to match the coordinates to.  

**INPUT PARAMETERS**

The BGC program classifies sequence alignments into 5 groups based on the user-supplied filtering parameters.  These groups are: 

1) PASSING: A passing alignment has only 1 significant alignment with equal to or higher than the user-defined percentage of identical positions (BLAST pident), and meets the user-defined BLAST minimum percent alignment length.  BLAST pident should be set near 100 percent.  Some amount of mismatch between genome builds is expected, and so setting the value at 100 may result in loss of true alignments.  The minimum percent alignment length helps avoid short near exact hits in multiple regions of a genome.  For example if your input sequence is 1000 bases, you may wish to consider alignments where at least 80 percent (or 800 base pairs) are aligned at the defined pident value. Conversely, alignments of only 100 base pairs are suspicious and you may not consider them valid alignments for the purpose of finding the whole gene sequence in the new genome build.

2) COMPLEX:  A complex alignment is one that may be considered potentially correct, but requiring of human review. For example, consider a BLAST result with multiple alignments in the same genomic region with passing pident, but much shorter than the user-defined BLAST minimum percent alignment length. This could represent a structural change between the two reference genomes (duplication, rearrangement, etc). To identify complex alignments, the user-defined percent overlap for complex value is used.  The default is currently set to 25 percent. In this case, a gene is considered complex if there is more than one alignment at or above the defined pident and the alignments are at least 25 percent the length of the input sequence.  Such genes are reported separately for the user to determine the best gene model for downstream analysis.

3) FAILED: A gene is considered a failure if there is only alignment at or above the defined pident, and the percentage of aligned bases is below the user-defined threshold.

4) COMPLEX FAILURE: A complex failure is one where there are more than one alignment meeting the defined pident, but the sum of aligned bases falls below the user-defined percent overlap for complex value.

5) NO SIGNIFICANT ALIGNMENT: This represents cases where there are no alignments for a gene sequence that meet the user-defined pident.

**OUTPUT FILES**

Six output files are created by the program. These are found in the directory created by the program. 

*CONTENTS OF THE OUTPUT DIRECTORY*

BGC_PassingGenes.bed: This is the primary output file of the program. This file is used as input in the WGS analysis pipeline. 

BGC_Summary.txt: This file summarizes the number and name of genes falling into each of the 5 defined categories. 

FastaSeqs_SubmittedGenes.fasta: The FASTA sequence for each gene derived from the original genome. 

All_BLAST_Data_BGC: BLAST output of all data. This file can be useful in troubleshooting failed alignments. 

AllFirstPassBlastDataEvaluated_BGC: All data passing the user-defined pident, also useful for troubleshooting. 

BGC.log: The log file captures all user parameters and is useful when debugging. 


REFERENCES:
       
    1. Altschul SF, Gish W, Miller W, Myers EW, Lipman DJ. Basic local alignment search tool. J Mol Biol. 1990 Oct 5;215(3):403–10.
