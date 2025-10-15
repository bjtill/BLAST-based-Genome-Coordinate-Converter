#!/bin/bash
#BT October 6, 2025
curl https://raw.githubusercontent.com/bjtill/BLAST-based-Genome-Coordinate-Converter/refs/heads/main/BGC_Images/BGC_long.jpg > long.jpeg
YADINPUT=$(yad --width=1200 --title="BLAST-based Genome coordinate Converter (BGC)" --image=long.jpeg --text="Version 1.0

ABOUT: Converts coordinates from one genome build to another using BLAST alignments. Note you can make the BED file input for this program using the GTF-Gene-Exctrator program at https://bjtill.github.io/gtf_extractor_V1_1.html

NOTE: Bed file must have four columns with a unique name in the fourth.  

Percent overlap for complex: When you have multiple alignments, how much of the gene needs to align to report it for a human to evaluate?  

Percent identical positions: Blast pident. Usually best to not use 100 owing to mismatches in genome builds. 

Minimum percent alignment length: How much of supplied sequence must match the new genome to be considered a passing hit?  

VERSION INFORMATION: October 14, 2025 BT" --form --field="CLICK FOR DETAILED INSTRUCTIONS:FBTN" 'xdg-open https://github.com/bjtill/BLAST-based-Genome-Coordinate-Converter' --field="Your Initials for the log file" "Enter" --field "Optional Notes" "Enter" --field="Percent overlap for complex alignment reporting (click to edit):CBE" '25!5!10!50!100' --field="BLAST Percent Identical Positions (Click to edit):CBE" '99!95!90!85!80' --field="BLAST minimum percent alignment length (Click to edit):CBE" '80!100!95!90!85' --field="Select BED file:FL" --field="Select original genome FASTA:FL" --field="Select new genome FASTA :FL" --field="Name for new directory. Your data will be in here. CAUTION-No spaces or symbols" "Enter" )
echo $YADINPUT |  tr '|' '\t' | datamash transpose | head -n -1  > mvgparm1

#######################################################################################################################

a=$(awk 'NR==10 {print $1}' mvgparm1) 

if [ "$a" == "" ]; 
 
then

zenity --width 1200 --warning --text='<span font="32" foreground="red">You forgot to enter a directory name. </span> \n You may have forgotten something else too. Please close and start over.' --title="INFORMATION ENTRY FAILURE" 
rm long.jpeg
exit
fi 
rm long.jpeg 

#######################################################################################################################
#Enter the directory
b=$(awk 'NR==10 {print $1}' mvgparm1)
mkdir ${b}
mv mvgparm1 ./${b}/
cd ${b}
curl https://raw.githubusercontent.com/bjtill/BLAST-based-Genome-Coordinate-Converter/refs/heads/main/BGC_Images/BGC_Square.jpg > square.jpeg
#######################################################################################################################
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>mvgt.log 2>&1
now=$(date)  
echo "BGC Version 1.0
Program Started $now" 
{
echo "# Checking if existing blastdb for new genome and making one if not."; sleep 2 
e=$(awk 'NR==9{print $1}' mvgparm1) #ref genome

if [ ! -f $e.ndb ] || [ ! -f $e.nhr ] || [ ! -f $e.nin ] || [ ! -f $e.nog ] || [ ! -f $e.nos ] || [ ! -f $e.not ] || [ ! -f $e.nsq ] || [ ! -f $e.ntf ] || [ ! -f $e.nto ] ; 
then 

makeblastdb -in ${e} -parse_seqids -dbtype nucl

fi 

######################################################################################################################

echo "# Extracting DNA sequence from old genome."; sleep 2 
d=$(awk 'NR==7{print $0}' mvgparm1) #bedfile
e=$(awk 'NR==8{print $0}' mvgparm1) #oldgenome

#make the gene length file for later filtering here:  
awk '{if ($3>$2) print $4, $3-$2; else print $4, $2-$3}' ${d} > genelength

bedtools getfasta -fi ${e} -bed ${d} -nameOnly > Remap_Fastas.fasta

echo "# Chunking the fasta to increase BLAST speed."; sleep 2

#in the future chunks could be set to # CPUs selected. If < 12, using 100% of computer, but should be pretty fast.  Or could bump this up for improved performance on JD, but this would max at 30.  Probably not a big deal for R&D.  

f=$(wc -l Remap_Fastas.fasta | awk '{print $1/24}')

awk -v seqs_per_chunk=${f} -v prefix="query_chunk_" 'BEGIN{chunk_num=1; seq_count=0; filename=prefix sprintf("%04d.fasta", chunk_num)} /^>/{if(seq_count>=seqs_per_chunk && seq_count>0){close(filename); chunk_num++; filename=prefix sprintf("%04d.fasta", chunk_num); seq_count=0} seq_count++} {print > filename} END{close(filename); print "Created " chunk_num " chunks"}' Remap_Fastas.fasta

echo "# Done chunking. Running parallel BLAST."; sleep 2
#note that this is a bit slow and the parallel seems to be non-parallel most of the time.  I could to the split/wait method I used for the FiG GiV stuff.
g=$(awk 'NR==9{print $1}' mvgparm1) #new genome
for chunk in query_chunk_*; do
blastn -db ${g} -query $chunk -outfmt 6 -out ${chunk}.results2 &
 
done
wait

# Concatenate results
cat query_chunk_*.results2 > final_results.txt 

echo "# BLAST finished. Filtering and creating summary files."; sleep 2

awk '{print $1}' genelength > genes

while IFS= read -r line; do
f=$(echo "$line" | awk '{print $1}' | awk '!visited[$1]++')
g=$(awk 'NR==5{print $1}' mvgparm1) #pident
h=$(awk 'NR==4{print $1}' mvgparm1) #complex overlap
i=$(awk 'NR==6{print $1}' mvgparm1) #alignment length
#alignment considered garbage if doesnt reach pident
j=$(awk -v var=${f} '{if ($1==var) print $2}' genelength) 
awk -v var=${f} -v var2=${g} '{if ($1==var && $3>=var2) print $0}' final_results.txt | awk -v var=${h} -v var2=${j} '{if ((($4/var2)*100) >= var) print $0}' > ${f}.putpassingcomplex
k=$(wc -l ${f}.putpassingcomplex | awk '{print $1}')
#awk -v var=${k} 'NR==1{print var}' genelength > ${f}.kvariabletodelete
awk -v var=${k} -v var2=${g} -v var3=${i} -v var4=${j} '{if (var==1 && ((($4/var4)*100) >= var3)) print $0}' ${f}.putpassingcomplex > ${f}.passing  
awk -v var=${k} -v var2=${g} -v var3=${i} -v var4=${j} '{if (var==1 && ((($4/var4)*100) < var3)) print $0}' ${f}.putpassingcomplex > ${f}.failing
awk -v var=${k} -v var2=${f} '{if (var=0) print var2, "CompleteAlignmentFailure"}' ${f}.putpassingcomplex > ${f}.noalignment
awk -v var=${k} -v var2=${g} -v var3=${i} -v var4=${j} '{sum +=$4; if (var>1 && ((sum/var4)*100)>=var2) print $0}' ${f}.putpassingcomplex > ${f}.complex
awk -v var=${k} -v var2=${g} -v var3=${i} -v var4=${j} '{sum +=$4; if (var>1 && ((sum/var4)*100)<var2) print $0}' ${f}.putpassingcomplex > ${f}.failingcomplex
find . -name ${f}.passing -type f -empty -delete
find . -name ${f}.failing -type f -empty -delete
find . -name ${f}.noalignment -type f -empty -delete
find . -name ${f}.complex -type f -empty -delete
find . -name ${f}.failingcomplex -type f -empty -delete
done < genes

#Keep everything that passed pident filter

g=$(date +"%m_%d_%y_at_%H_%M")
cat *.putpassingcomplex > AllFirstPassBlastDataEvaluated_BGC_${g}.txt
rm *.putpassingcomplex
rm query_chunk_*

#make bed file of passing, which should only ever be 1 row /gene
g=$(date +"%m_%d_%y_at_%H_%M")
cat *passing | awk '{print $2, $9, $10, $1}' | tr ' ' '\t'  > BGC_PassingGenes_${g}.bed
#in case no passing
find . -name BGC_PassingGenes_${g}.bed -type f -empty -delete

#Everything else is captured in the AllBlastData, and can let users sort that out. But keep final results for everything 


g=$(date +"%m_%d_%y_at_%H_%M")
m=$(ls *.passing | wc -l | awk '{print $1}')
n=$(shopt -s nullglob; files=(*.passing); [ ${#files[@]} -eq 0 ] && echo "NA" || printf '%s\n' "${files[@]%.passing}" | paste -sd, )

o=$(ls *.failing | wc -l | awk '{print $1}')
p=$(shopt -s nullglob; files=(*.failing); [ ${#files[@]} -eq 0 ] && echo "NA" || printf '%s\n' "${files[@]%.failing}" | paste -sd,)
q=$(ls *.nonalignment | wc -l | awk '{print $1}')
r=$(shopt -s nullglob; files=(*.nonalignment ); [ ${#files[@]} -eq 0 ] && echo "NA" || printf '%s\n' "${files[@]%.nonalignment}" | paste -sd,)
s=$(ls *.complex | wc -l | awk '{print $1}')
t=$(shopt -s nullglob; files=(*.complex ); [ ${#files[@]} -eq 0 ] && echo "NA" || printf '%s\n' "${files[@]%.complex}" | paste -sd,)
u=$(ls *.failingcomplex | wc -l | awk '{print $1}')
v=$(shopt -s nullglob; files=(*.failingcomplex ); [ ${#files[@]} -eq 0 ] && echo "NA" || printf '%s\n' "${files[@]%.failingcomplex }" | paste -sd,)
w=$(awk -F'/' 'NR==7{print $NF}' mvgparm1) #bedfile
x=$(awk -F'/' 'NR==8{print $NF}' mvgparm1) #origgenome
y=$(awk -F'/' 'NR==9{print $NF}' mvgparm1) #newgenome 

printf 'BGC Version 1.0: %s\n\nSummary of genes re-mapped from %s to %s \n\nBed file used: %s \n\n************************************************************************ \nCATEGORY COUNT GENES \nPASSING %s %s \nFAILED %s %s \nNO_SIGNIFICANT_ALIGNMENT %s %s \nCOMPLEX %s %s \nCOMPLEX_FAILURE %s %s \n************************************************************************' $g $x $y $w $m $n $o $p $q $r $s $t $u $v > BGC_Summary_${g}.txt


echo "#Tidying."; sleep 2 
g=$(date +"%m_%d_%y_at_%H_%M")
mv Remap_Fastas.fasta FastaSeqs_SubmittedGenes_BGC_${g}.fasta
mv final_results.txt All_BLAST_Data_BGC_${g}.txt
rm genes genelength

#Note that if exceed limits of rm with high gene numnber, switch to xargs (not sure if we will ever get that high with this tool - and if yes, would have to re-build chunks with FiG like multi-threading

rm *.complex 
rm *.passing
rm *.failing
rm *.nonalignment
rm *.failingcomplex

} | yad --progress --image=square.jpeg --title "PROGRESS" --text "BLAST-based Genome coordinate Converter (BGC)\nVersion 1.0\n\n" --width=700 --pulsate --button=EXIT --auto-kill --ltr --auto-close
now=$(date)
echo "Program Finished" $now

printf '\nInitials of person who ran the program: \nUser notes: \nPercent overlap for complex alignment reporting \nBLAST Percent Identical mathces: \nBLAST mimimum percent alignment: \nBED file: \nOriginal genome: \nNew genome: \nName of directory created for this analysis:' > plog
paste plog mvgparm1 | tr '\t' ' '  > plog2
c=$(date +"%m_%d_%y")
grep -v "ls:" mvgt.log | cat - plog2 | grep -v "rm: cannot remove" > BGC_${c}.log
rm mvgt.log plog plog2 mvgparm1 square.jpeg

#######################END OF PROGRAM##################################################################################


