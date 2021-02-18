GATK4SCNA pipeline
==================

This pipeline build for CPTAC2/3 projects to call somatic copy number alterations from  whole exome sequencing (WXS) data. The pipeline implements panel of normals (PoN) approach.


* Version v0.1
	
	> This version can only be used in MGI-Server (LSF).


Tutorial
---------------
* https://gatk.broadinstitute.org/hc/en-us/articles/360035531092#2
* https://gatk.broadinstitute.org/hc/en-us/articles/360035890011

Requirements
-------------

### Install

```
GATK v4.1.9.0
bedtools v2.30.0
Python3
```

### Set database

* Genome

	> GRCh38.d1.vd1.fa & GRCh38.d1.vd1.dict

* Target

	> targets.preprocessed.exome.interval_list
	
* Allelic data

	> af-only-gnomad.hg38.common_biallelic.chr1-22XY.vcf

* Protein coding genes

	> gencode.gene.info.v22.protein_coding.chr1-22.v2.tsv


[Note] Please refer to config/config.gatk4scna.mgi.ini


### Input

```
* make table
  CaseID	NormalBam	TumorBam	Disease
```



Usage
-------

[Note] Set `config.ini` location to `gatk_somatic.cnv.mgi.sh`

```

1. CollectFragmentCounts for Normal Bam
   `sh gatk_somatic.cnv.mgi.sh -p precall -t ./bam.catalog -o ./gatk4scna`
    
2. Make pool normal
   `sh gatk_somatic.cnv.mgi.sh -p pon -o ./gatk4scna`
    
3. Call tumor cnv based on pool normal
   `sh gatk_somatic.cnv.mgi.sh -p callcn -t bam.catalog -o ./gatk4scna`

4. Call gene-level
   `sh gatk_somatic.cnv.mgi.sh -p geneLevel -t BRCA.paired.bam.catalog -o ./gatk4scna`
    
5. Merge gene-level files to one merged one  
   `sh gatk_somatic.cnv.mgi.sh -p merge_geneLevel -o ./gatk4scna`

```


Contact
-------------
Hua Sun, <hua.sun@wustl.edu>

