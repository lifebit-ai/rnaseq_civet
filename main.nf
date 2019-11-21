#!/usr/bin/env nextflow
/*
========================================================================================
                         lifebit-ai/rnaseq_civet
========================================================================================
 lifebit-ai/rnaseq_civet
 #### Homepage / Documentation
 https://github.com/lifebit-ai/rnaseq_civet
----------------------------------------------------------------------------------------
*/

Channel
  .fromFilePairs( params.reads, size: params.singleEnd ? 1 : 2 )
  .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nNB: Path requires at least one * wildcard!\nIf this is single-end data, please specify --singleEnd on the command line." }
  .set { raw_reads }

/*--------------------------------------------------
  Filter/trim input reads
---------------------------------------------------*/

process qual_stat {
  tag "$name"
  publishDir "${params.outdir}", mode: 'copy'

  input:
  set val(name), file(reads) from raw_reads

  output:
  file "filter" into filtered_reads

  script:
  """
  mkdir filter
  filter_trim.py -M 50 -d filter ${reads[0]} ${reads[1]}
  """
}