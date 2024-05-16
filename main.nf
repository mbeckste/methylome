// CloWM demonstration workflow for mapping of paired end bisulfite treated reads
//
// The genome reference sequence is a registered resource in CloWM


// process for mapping of paired end reads using Bismark
process bismark {
   label 'highmemLarge'
   container "chrishah/bismark:latest"
   publishDir params.outdir, mode: 'copy'
   shell '/bin/bash', '-euo', 'pipefail'

   input:
     tuple val(sampleID), file(reads)

   output:
       tuple val(sampleID), path("${params.run_name}/*")

  script:
  """
   MY_TMP=\$(mktemp -d)
   mkdir ${params.run_name}
   # Mapping of bisulfite treated reads
   bismark --gzip --bowtie2 --fastq  -p ${params.threads} --basename ${sampleID}  --output_dir ${params.run_name}  --temp_dir \$MY_TMP ${params.bismark_index_dir} -N 1 -1 ${reads[0]} -2 ${reads[1]}
   
   # Deduplication/ Removal of PCR artefacts
   deduplicate_bismark --paired --bam --output_dir ${params.run_name} -o ${sampleID} ${params.run_name}/${sampleID}*pe.bam 
   
   # Extract methyltion values/Call Methylation Extractor
   # bismark_methylation_extractor --gzip --parallel ${params.threads} --paired-end  --no_overlap --output ${params.run_name} --bedGraph --counts --buffer_size 10G --cutoff ${params.min_coverage} --cytosine_report --genome_folder ${params.bismark_index_dir} --report ${params.run_name}/${sampleID}.deduplicated.bam
   bismark_methylation_extractor --gzip --parallel ${params.threads} --paired-end  --no_overlap --comprehensive --output ${params.run_name} --bedGraph --counts --cutoff ${params.min_coverage} --buffer_size 20G  --genome_folder ${params.bismark_index_dir} --report ${params.run_name}/${sampleID}.deduplicated.bam
   
   # Generation of per sample report
   bismark2report --dir ${params.run_name} --alignment_report ${params.run_name}/${sampleID}_PE_report.txt --dedup_report ${params.run_name}/${sampleID}_pe.deduplication_report.txt --splitting_report ${params.run_name}/${sampleID}.deduplicated_splitting_report.txt --mbias_report ${params.run_name}/${sampleID}.deduplicated.M-bias.txt --nucleotide_report none --output ${sampleID}_report.html
   rm -r \$MY_TMP
  """
}

process summary_report {
   label 'large'
   container "chrishah/bismark:latest"
   publishDir params.outdir + "/" + params.run_name, mode: 'copy'
   shell '/bin/bash', '-euo', 'pipefail'

   input:
     path("${params.run_name}/*")

   output:
     path("${params.run_name}_bismark_summary*")

   script:
   """
    bismark2summary --basename "${params.run_name}_bismark_summary" --title "${params.summary_report_title}" ${params.run_name}/*_pe.bam 
   """
}



// Completion mail handler
workflow.onComplete {

def msg = """\
Workflow execution summary
	---------------------------
	ScriptName     : ${workflow.scriptName}
	Repository     : ${workflow.repository}
	Run            : ${workflow.runName}
	Commandline    : ${workflow.commandLine}
	Configfiles    : ${workflow.configFiles}
	workDir        : ${workflow.workDir}
	Start time     : ${workflow.start}
	Completed at   : ${workflow.complete}
	Duration       : ${workflow.duration}
	exit status    : ${workflow.exitStatus}
	Success        : ${workflow.success ? 'OK' : 'failed' }
	Error message  : ${workflow.errorMessage}
	Error report   : ${workflow.errorReport}
	ContainerEngine: ${workflow.containerEngine}
	Container(s)   : ${workflow.container}
	Nextflow ver.  : ${nextflow.version}
	Nextflow build : ${nextflow.build}
        """
        .stripIndent()
	if (params.email?.trim()) {
          sendMail(to: "${params.email}", from: "${params.mailfrom}", subject: 'Methylome analysis workflow execution report', body: msg)
        }
	else {
          // no Email adress set (params.email == empty or null)
        }
}








workflow {
  Channel.fromFilePairs("${params.indir}/*_{1,2}.fastq", checkIfExists:true) \
  | bismark \
  | map{sampleID,files -> files} \
  | collect \
  | summary_report
}


