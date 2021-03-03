#!/bin/bash

# Hua Sun
# hua.sun@wustl.edu

# 2021-02-02 v0.2
# 2021-01-30 v0.1


## USAGE:
# Note: Please set config.ini before running pipeline

# sh gatk_somatic.cnv.sh -c <config.ini> -p <programname> -t <table> -o <outdir>



submitJob=/gscmnt/gc3021/dinglab/hsun/Toolkit/LSF_mgi/lsf_submit.sh


# set script dir
scriptDir=/gscuser/hua.sun/scripts/gatk4scna

# set config.ini
config=${scriptDir}/config.gatk4scna.mgi.ini

CNVPON=''
outdir='.'
hdf5Dir=''
while getopts "c:p:t:d:n:o:" opt; do
  case $opt in
    c)
      config=$OPTARG
      ;;
    p)
      program=$OPTARG
      ;;
    t)
      table=$OPTARG
      ;;
    d)
      hdf5Dir=$OPTARG
      ;;
    n)
      CNVPON=$OPTARG
      ;;
    o)
      outdir=$OPTARG
      ;;
    \?)
      echo "script usage: $(basename $0) [-t] [-n] " >&2
      exit 1
      ;;
  esac
done


source $config



###############################
##  STEP-1   Pre-call for normal
###############################

if [[ $program == "precall" ]] || [[ $program == "s1" ]]; then

    if [ ! -e $table ]; then
        echo "[ERROR] The Table $table is not exists !" 1>&2
        exit
    fi
    
    if [ ! -d $outdir ]; then
        echo "[ERROR] The OutDir $outdir is not exists !" 1>&2
        exit
    fi
    
    
    sed '1d' $table | cut -f 1-3 | while read caseID normalBam tumorBam
    do
        sh $submitJob 4 1 gatk4cn.s1.${name} "bash $scriptDir/src/1.run.gatk4scna.collectReadCounts.Normal.sh -C ${config} -N ${caseID} -T Normal -B ${normalBam} -O ${outdir}"
    done

fi



###############################
##  STEP-2   Pool Normal
###############################

if [[ $program == "pon" ]] || [[ $program == "s2" ]]; then
    
    if [[ $hdf5Dir == '' ]]; then
        hdf5Dir=$outdir/PON
    fi
    
    sh $submitJob 8 1 gatk4cn.s2.pon "bash $scriptDir/src/2.run.gatk4scna.createPON.sh -C ${config} -D ${hdf5Dir}"

fi




###############################
##  STEP-3   Call total cn
###############################


if [[ $program == "callcn" ]] || [[ $program == "s3" ]]; then
    
    if [[ $CNVPON == '' ]]; then
        CNVPON="$outdir/PON/gatk4scnaPON.Normal.hdf5"
    fi
    
    sed '1d' $table | cut -f 1-3 | while read caseID normalBam tumorBam
    do    
        sh $submitJob 16 1 gatk4cn.s3.${caseID} "bash $scriptDir/src/3.run.gatk4scna.callCNA.pair.sh -C ${config} -P ${CNVPON} -S ${caseID} -N ${normalBam} -T ${tumorBam} -O ${outdir}"
    done
    
fi



###############################
##  STEP-4   plot
###############################


if [[ $program == "plot" ]] || [[ $program == "s4" ]]; then
    
    
    sed '1d' $table | cut -f 1 | while read caseID 
    do    
        sh $submitJob 8 1 gatk4cn.s4.${caseID} "bash $scriptDir/src/4.run.gatk4scna.plot.sh -C ${config} -S ${caseID} -O ${outdir}"
    done
    
fi



###############################
##  STEP-5   gene-level
###############################

if [[ $program == "geneLevel" ]] || [[ $program == "s5" ]]; then
    
    
    sed '1d' $table | cut -f 1 | while read caseID 
    do  
        DIR=${outdir}/${caseID}
        sh $submitJob 1 1 gatk4cn.s5.${caseID} "${PYTHON3} $scriptDir/src/segment_to_geneLevel.py --prefix ${caseID}.T --name ${caseID} --seg ${DIR}/${caseID}.T.called.igv.seg --gene ${ProteinCodingGene} -o ${DIR}"
    done
    
fi




###############################
##  STEP-6  merge gene-level
###############################

if [[ $program == "merge" ]] || [[ $program == "s6" ]]; then
    
    sh $submitJob 2 1 gatk4cn.s6.${caseID} "${PYTHON3} $scriptDir/src/mergeMultipleFilesToOne.py ${outdir}"
    
fi


