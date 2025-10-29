# Outputs 

## Reports

<details markdown=1>
<summary>reports</summary>

Reports are stored in the sub-folder "reports". 

Sample.xlsx - A xlsx formatted table with each analysed sequence and the matched taxon
Sample.pdf - The primary report in PDF Format, including taxonomic assignment and supporting evidence
Sample.summary.json - A summary of all sample-level results in JSON format

</details>

## Quality control

<details markdown=1>
<summary>MultiQC</summary>

- MultiQC/`name_of_pipeline_run`_multiqc_report.html: A graphical and interactive report of various QC steps and results

</details>

## Pipeline run metrics

<details markdown=1>
<summary>pipeline_info</summary>

This folder contains the pipeline run metrics

- pipeline_dag.svg - the workflow graph (only available if GraphViz is installed)
- pipeline_report.html - the (graphical) summary of all completed tasks and their resource usage
- pipeline_report.txt - a short summary of this analysis run in text format
- pipeline_timeline.html - chronological report of compute tasks and their duration
- pipeline_trace.txt - Detailed trace log of all processes and their various metrics

</details>
