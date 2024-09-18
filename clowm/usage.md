## Usage

To execute the workflow the following parameters are **mandatory**:

* `--indir`: S3 path to a CloWM bucket/folder containing paired end FastQ files as input. Filenames must match the following pattern *_{1,2}.fastq
* `--outdir`: S3 path to a CloWM bucket/folder where the result files will be written. Bucket/folder has to be writeable!
* `--run_name`: Name of the analysis. The `run_name`will be used as a prefix for naming of result files.
* `--bismark_index_dir`: Selection of the reference genome for read mapping.

Additional **optional** parameters:

* `--summary_report_title`: Title for the summary report (default: My report)
* `--threads`: Number of CPU cores used for read mapping and methylation value calling (default: 8). This value is limited by the available resources of the underlying execution layer.
* `--min_coverage`: minimal number of mapped reads (coverage) for CpG,CHH and CHG motifs necessary for methylation value calling. Default: 5
* `--email`: Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If not set, no notification will be send.

#### Current limitations of the workflow
As already mentioned in the README, this workflow is mainly meant for educational purposes and to get familiar with the development of Nextflow workflows for the CloWM platform. 
For this reason uncompressed paired end FastQ files are so far supported only. Moreover, only one paired end library per sample is supported. Nevertheless the workflow might be useful for some basic analyses.
