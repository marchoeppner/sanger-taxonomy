#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/**
===============================
Sanger taxonomy pipeline
===============================

This Pipeline performs taxonomic profiling of Sanger-sequenced amplicons

### Homepage / git
git@github.com:marchoeppner/pipeline.git

**/

include { SANGER_TAXONOMY }         from './workflows/sanger_taxonomy'
include { BUILD_REFERENCES }        from './workflows/build_references'
include { PIPELINE_COMPLETION }     from './subworkflows/pipeline_completion'

workflow {

    WorkflowMain.initialise(workflow, params, log)
    WorkflowPipeline.initialise(params, log)

    if (params.build_references) {
        BUILD_REFERENCES()
    } else {
        SANGER_TAXONOMY()
    }

    PIPELINE_COMPLETION()
    
}
