# Methylome analysis using Bismark
CloWM workflow using Bismark for mapping of bisulfite paired-end data.
This workflow is mainly meant for educational purposes and demonstrates how to use workflows and persistent resources in the Cloud based Workflow Manager CloWM.

## Workflow
The workflow automates the main steps necessary for methylome analysis using bisulfite treated reads:

### 1. Read mapping
Bisulfite treated paired end reads will be mapped against a reference genome. The reference genome which is available as a persistant reosurce on the CloWM plattform is selected by parameter `--bismark_index_dir`. 
For read mapping the bisulfite read mapper Bismark (Krueger et al. 2011) is used. 
### 2. Deduplication/Removal of PCR artefacts
Deduplication is performed with program `deduplicate_bismark`
### 3. Methylation value calling
Methylation values (determination of cytosine methylation state) for all CpG, CHG and CHH motifs with a coverage of at least 5 (default, can be adjusted with parameter `--min_coverage`) are called.
### 4. Generation of a per sample report
Generation of per sample Bismark processing report (`bismark2report`) containing alignment statistics and methylation value summary statistics 
### 5. Summary report generation
Aggregation of per sample reports into comprehensive summary report (`bismark2summary`)

## Getting started
Example data with appropriate parametrization for an easy try-out of the workflow is available by clicking on the `Try it out` button on the parameter form page.


## Citation
This workflow automates the main steps necessary for methylome analysis by using the Bismark package. If you use this workflow please cite:

#### Krueger F, Andrews SR. Bismark: a flexible aligner and methylation caller for Bisulfite-Seq applications.Bioinformatics. 2011 Jun 1;27(11):1571-2



