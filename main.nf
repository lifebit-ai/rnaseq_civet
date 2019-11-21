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
Channel
  .fromPath (params.fasta)
  .ifEmpty { exit 1, "FASTA file not found ${params.fasta}" }
  .set { fasta }
Channel
  .fromPath (params.gtf)
  .ifEmpty { exit 1, "GTF file not found ${params.gtf}" }
  .set { gtf }

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
  file "**filtered_trimmed" into filtered_trimmed

  script:
  """
  mkdir filter
  filter_trim.py -M 50 -d filter ${reads[0]} ${reads[1]}
  """
}

/*--------------------------------------------------
  Index 
---------------------------------------------------*/

fasta_file =  file(params.fasta)
index = file("${fasta_file.baseName}.1.bt2")
if ( !index.exists() ) {
  process index {
  tag "$gtf"
  publishDir "${params.outdir}/index", mode: 'copy'

  input:
  each file(gtf) from gtf
  each file(fasta) from fasta

  output:
  file "*" into indexed

  script:
  """
  rsem-prepare-reference --gtf $gtf --bowtie2  $fasta ${fasta.baseName}
  """
  }
}

/*--------------------------------------------------
  Alignment expression
---------------------------------------------------*/

// process alignment_expression {
//   tag "$name"
//   publishDir "${params.outdir}", mode: 'copy'

//   input:
//   set val(name), file(reads) from filtered_trimmed
//   each file(fasta) from fasta

//   output:
//   file "filter" into filtered_reads

//   script:
//   """
//   rsem-calculate-expression -p ${task.cpus} ${params.phredquals} --seed-length ${params.seed_length} --forward-prob ${params.strand_specific} --time --output-genome-bam --bowtie2 --paired-end ${reads[0]} ${reads[1]} ${fasta.baseName} $name
//   """
// }