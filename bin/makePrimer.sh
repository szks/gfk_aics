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


#RUN cp ${SHAREDDIR}/allGenes.fasta ./transcripts.allGene_cuff.${rank}.fasta
RUN ln -s ${SHAREDDIR}/allGenes.fasta ./transcripts.allGene_cuff.${rank}.fasta


# mapping the contigs to the .fasta file
RUN ${GFKDIR}/blat -maxIntron=5 ./transcripts.allGene_cuff.${rank}.fasta ./juncContig.${rank}.fa ./juncContig_allGene_cuff.${rank}.psl

#cat ./juncContig_allGene_cuff.${rank}.psl.* > ./juncContig_allGene_cuff.${rank}.psl
RUN python ${GFKDIR}/merge_psl.py ${OMP_NUM_THREADS} juncContig_allGene_cuff.${rank}.psl

#rm -f ./juncContig_allGene_cuff.${rank}.psl.*


RUN_PERL ${GFKDIR}/psl2bed_junc.pl ./juncContig_allGene_cuff.${rank}.psl > ./juncContig_allGene_cuff.${rank}.bed


if [ -f ./transcripts.allGene_cuff.${rank}.fasta.fai ]; then
  #echo "rm -rf ${FUSIONDIR}/transcripts.allGene_cuff.fasta.fai"
  rm -rf ./transcripts.allGene_cuff.${rank}.fasta.fai
fi


RUN ${GFKDIR}/fastaFromBed -fi ./transcripts.allGene_cuff.${rank}.fasta -bed ./juncContig_allGene_cuff.${rank}.bed -fo ./juncContig_allGene_cuff.${rank}.txt -tab -name -s

RUN_PERL ${GFKDIR}/summarizeExtendedContig.pl ./juncList_anno7.${rank}.txt ./juncContig_allGene_cuff.${rank}.txt | uniq > ./comb2eContig.${rank}.txt

RUN_PERL ${GFKDIR}/psl2inframePair.pl ./juncContig_allGene_cuff.${rank}.psl ${SHAREDDIR}/codingInfo.txt > ./comb2inframe.${rank}.txt

RUN_PERL ${GFKDIR}/psl2geneRegion.pl ./juncContig_allGene_cuff.${rank}.psl ${SHAREDDIR}/codingInfo.txt > ./comb2geneRegion.${rank}.txt

RUN_PERL ${GFKDIR}/addGeneral.pl ./juncList_anno7.${rank}.txt ./comb2eContig.${rank}.txt 2 > ./juncList_anno8.${rank}.txt

RUN_PERL ${GFKDIR}/addGeneral.pl ./juncList_anno8.${rank}.txt ./comb2inframe.${rank}.txt 1 > ./juncList_anno9.${rank}.txt

RUN_PERL ${GFKDIR}/addGeneral.pl ./juncList_anno9.${rank}.txt ./comb2geneRegion.${rank}.txt 2 > ./juncList_anno10.${rank}.txt

RUN_PERL ${GFKDIR}/addHeader.pl ./juncList_anno10.${rank}.txt > ./fusion.all.${rank}.txt

RUN_PERL ${GFKDIR}/filterMaltiMap.pl ./fusion.all.${rank}.txt > ./fusion.filt1.${rank}.txt

RUN_PERL ${GFKDIR}/filterColumns.pl ./fusion.filt1.${rank}.txt > ./fusion.${rank}.txt


# HOKUSHAI
if [ "$PJM_RSCUNIT" = "gwmpc" -o  "$PJM_RSCUNIT" = "gwacsg" ]; then
        ln -f ./fusion.${rank}.txt ../Output/fusion.${rank}.txt
fi
