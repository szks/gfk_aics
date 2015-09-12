#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
rank=$3
myrank=0

. $GFKDIR/common.sh

cat_com2seq_tmp() {
        ls ${SHAREDDIR}/comb2seq.tmp.${rank}.*.txt |\
            xargs cat > comb2seq.tmp.${rank}.txt
       #ls ${SHAREDDIR}/comb2seq.tmp.${rank}.*.txt | xargs rm -f
}


RUN cat_com2seq_tmp

# process the above data and complete the table for relationships between combinations of junctions and their sequences
RUN_PERL ${GFKDIR}/procComb2seq.pl comb2seq.tmp.${rank}.txt > ./comb2seq.${rank}.txt


TMPCONTIGDIR=./tmp_contig/${rank}
if [ ! -d ${TMPCONTIGDIR} ]; then
    mkdir -p ${TMPCONTIGDIR}
fi

echo -n > ./candFusionContig.${rank}.fa
echo -n > ./candFusionPairNum.${rank}.txt

num=0
while read LINE; do 

  comb=`echo ${LINE} | cut -d ' ' -f 1`
  segseq=`echo ${LINE} | cut -d ' ' -f 2`
  ids=( `echo ${LINE} | cut -d ' ' -f 3 | tr -s ',' ' '` )
  seqs=( `echo ${LINE} | cut -d ' ' -f 4 | tr -s ',' ' '` )

  # make the fasta file for each junction pair 
  echo ${comb}
  echo -n > ${TMPCONTIGDIR}/candSeq_${num}.tmp.fa
  for (( i = 0; i < ${#seqs[@]}; i++ ))
  {
    echo '>'${ids[$i]}  >> ${TMPCONTIGDIR}/candSeq_${num}.tmp.fa 
    echo "${seqs[$i]}" >> ${TMPCONTIGDIR}/candSeq_${num}.tmp.fa
  }

  # if the number of reads exceeds 1000, then discard randomly to reach 1000 reads
  RUN_PERL ${GFKDIR}/randFasta.pl ${TMPCONTIGDIR}/candSeq_${num}.tmp.fa 1000 > ${TMPCONTIGDIR}/candSeq_${num}.fa

  # make the constraint file for the paired end sequences (maybe the constraint information is not reflected in CAP3 assembly?)
  RUN_PERL ${GFKDIR}/my_formcon.pl ${TMPCONTIGDIR}/candSeq_${num}.fa > ${TMPCONTIGDIR}/candSeq_${num}.fa.con


  # assemble the sequences via CAP3
  #echo "${CAP3_PATH}/cap3 ./tmp_contig/candSeq_${num}.fa -p 66 -o 16 > ./tmp_contig/candSeq_${num}.contig" >&
  RUN ${GFKDIR}/createSOAPconfig.sh ${TMPCONTIGDIR}/SOAP_config.txt ${TMPCONTIGDIR}/candSeq_${num}.fa
  RUN ${GFKDIR}/SOAPdenovo-Trans-31mer pregraph -s ${TMPCONTIGDIR}/SOAP_config.txt -K 13 -p 1 -o ${TMPCONTIGDIR}/candSeq_${num}
  RUN ${GFKDIR}/SOAPdenovo-Trans-31mer contig -g ${TMPCONTIGDIR}/candSeq_${num}

  FILE_SIZE=`cat ${TMPCONTIGDIR}/candSeq_${num}.contig | wc -c`

  #if [ -s ${TMPCONTIGDIR}/candSeq_${num}.contig ]; then
  if [ $FILE_SIZE -gt 0 ]; then
      echo "Contig file size = $FILE_SIZE ($num)" 1>&2
      # alignment the junction sequence to the set of contigs generated via CAP3 and select the best contig
      echo '>'query > ${TMPCONTIGDIR}/query_${num}.fa
      echo ${segseq} >> ${TMPCONTIGDIR}/query_${num}.fa
      RUN ${GFKDIR}/fasta36 -d 1 -m 8 ${TMPCONTIGDIR}/query_${num}.fa ${TMPCONTIGDIR}/candSeq_${num}.contig > ${TMPCONTIGDIR}/candSeq_${num}.contigs.fastaTabular


      RUN_PERL ${GFKDIR}/selectContig.pl ${TMPCONTIGDIR}/candSeq_${num}.contigs.fastaTabular ${TMPCONTIGDIR}/candSeq_${num}.contig > ${TMPCONTIGDIR}/candSeq_${num}.contigs.selected
      if [ $? -ne 0 ]; then
	  echo "Error at selectContig.pl, NUM=${num}"
	  exit
      fi

      # This step is skipped because SOAP outputs are already forward-reverse compliment.
      # count the number of read pairs aligned properly to the selected contig
      #echo "perl ../procAce.pl ./tmp_contig/candSeq_${num}.fa.cap.ace ./tmp_contig/candSeq_${num}.contigs.selected | sort -k 2 -n  > ./tmp_contig/candSeq_${num}.consensusPair"
      #perl ../procAce.pl ${TMPCONTIGDIR}/candSeq_${num}.fa.cap.ace ${TMPCONTIGDIR}/candSeq_${num}.contigs.selected | sort -k 2 -n  > ${TMPCONTIGDIR}/candSeq_${num}.consensusPair

      # get the contig sequence and add it to the candFusionContig.fa file
      echo ">"${comb} >> ./candFusionContig.${rank}.fa
      RUN_PERL ${GFKDIR}/extractContigSeq.pl ${TMPCONTIGDIR}/candSeq_${num}.contig ${TMPCONTIGDIR}/candSeq_${num}.contigs.selected >> ./candFusionContig.${rank}.fa
      if [ $? -ne 0 ]; then
	  echo "Error at extractContigSeq.pl, NUM=${num}"
	  exit
      fi


      # write the number of properly alinged read pairs to the candFusionPairNum.txt file
      ## right_pair_num=`awk 'END{print NR}' ${TMPCONTIGDIR}/candSeq_${num}.consensusPair`
      # right_pair_num=`wc -l ./tmp_contig/candSeq_${num}.consensusPair | cut -d " " -f 1`
      #echo "echo -e "${comb}\t${right_pair_num}" >> ./candFusionPairNum.txt"
      ## echo -e "${comb}\t${right_pair_num}" >> ./candFusionPairNum.${rank}.txt

  fi

  num=`expr ${num} + 1`

done < ./comb2seq.${rank}.txt


RUN_PERL ${GFKDIR}/addContig.pl juncList_anno4.${rank}.txt ./candFusionContig.${rank}.fa > ./juncList_anno5.${rank}.txt


# aling the contigs split by the junction points to the genome including alternative assembly and filter if they are alinged to multiple locations
RUN_PERL ${GFKDIR}/makeJuncSeqPairFa.pl ./juncList_anno5.${rank}.txt > ./juncContig.${rank}.fa


RUN ${GFKDIR}/blat -stepSize=5 -repMatch=2253 -ooc=${SHAREDDIR}/11.ooc ${SHAREDDIR}/hg19.all.2bit ./juncContig.${rank}.fa ./juncContig.${rank}.psl
RUN python ${GFKDIR}/merge_psl.py ${OMP_NUM_THREADS} juncContig.${rank}.psl
rm -f ./juncContig.${rank}.psl.*

RUN_PERL ${GFKDIR}/filterByJunction.pl ./juncContig.${rank}.psl > ./juncContig.filter.${rank}.txt

RUN_PERL ${GFKDIR}/addFilterByJunction.pl ./juncList_anno5.${rank}.txt ./juncContig.filter.${rank}.txt > ./juncList_anno6.${rank}.txt


# echo "join -1 1 -2 1 -t'	'  ./juncList_anno6.txt ./candFusionPairNum.txt > ./juncList_anno7.txt"
# join -1 1 -2 1 -t'	'  ./juncList_anno6.txt ./candFusionPairNum.txt > ./juncList_anno7.txt

RUN_PERL ${GFKDIR}/joinFile.pl ./juncList_anno6.${rank}.txt > ./juncList_anno7.${rank}.txt

RUN_PERL ${GFKDIR}/addHeader.pl ./juncList_anno7.${rank}.txt > ./fusion.${rank}.txt
