// Modules
include { INPUT_CHECK }                 from './../modules/input_check'
include { MULTIQC }                     from './../modules/multiqc'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './../modules/custom/dumpsoftwareversions'
include { TRACY_CONSENSUS }             from './../modules/tracy/consensus'
include { TRACY_BASECALL }              from './../modules/tracy/basecall'
include { FASTQC }                      from './../modules/fastqc'

include { CUTADAPT_WORKFLOW }           from './../subworkflows/cutadapt'
include { BLAST_TAXONOMY }              from './../subworkflows/blast_taxonomy'
include { REPORTING }                   from './../subworkflows/reporting'

workflow SANGER_TAXONOMY {

    main:

    samplesheet =   params.input ? channel.fromPath(params.input, checkIfExists: true) : channel.value([])

    ch_multiqc_config = params.multiqc_config   ? channel.fromPath(params.multiqc_config, checkIfExists: true).collect() : channel.value([])
    ch_multiqc_logo   = params.multiqc_logo     ? channel.fromPath(params.multiqc_logo, checkIfExists: true).collect() : channel.value([])
    ch_logo           = params.logo             ? channel.fromPath(params.logo, checkIfExists: true).collect() : channel.fromPath("${baseDir}/assets/pipelinelogo.png").collect()

    ch_versions = channel.from([])
    multiqc_files = channel.from([])
    ch_reporting = channel.from([])

    pipeline_info = channel.fromPath(dumpParametersToJSON(params.outdir)).collect()
    
    if (params.input) {

        if (params.primer_set) {
            database = params.db
            blast_db = set_blast_db(database)
            ch_primers = file(params.fasta, checkIfExists: true)
            version = "NA"
        } else {
            blast_db = set_blast_db(params.db)
            version  = "user-supplied"
            ch_primers = file(params.primers_fa, checkIfExists: true)
        }

        if (params.reference_base) {
            tax_nodes           = file(params.references.taxonomy.nodes, checkIfExists: true)          // ncbi taxnomy node file
            tax_rankedlineage   = file(params.references.taxonomy.rankedlineage, checkIfExists: true)  // ncbi rankedlineage file
            tax_merged          = file(params.references.taxonomy.merged, checkIfExists: true)         // ncbi merged file
            ch_tax_files        = channel.of([ tax_nodes, tax_rankedlineage, tax_merged ])
            ch_taxdb            = channel.fromPath(params.references.taxonomy.taxdb, checkIfExists: true)
        }

        ch_blocklist = channel.fromPath(params.blocklist, checkIfExists: true)

        channel.fromPath(blast_db, checkIfExists: true).map { db ->
            [[id: params.db, version: version], db]
        }.set { ch_blast_db }
    }

    INPUT_CHECK(samplesheet)

    INPUT_CHECK.out.traces.branch {m,t ->
        single: t.size() == 1
        both: t.size() == 2
    }.set { traces_by_config }

    // Trace file consensus calling
    TRACY_CONSENSUS(
        traces_by_config.both
    )
    ch_reporting = ch_reporting.mix(TRACY_CONSENSUS.out.consensus_txt, TRACY_CONSENSUS.out.consensus)
    ch_versions = ch_versions.mix(TRACY_CONSENSUS.out.versions)

    // Trace file base calling
    TRACY_BASECALL(
        INPUT_CHECK.out.traces
    )
    ch_versions = ch_versions.mix(TRACY_BASECALL.out.versions)

    FASTQC(
        TRACY_BASECALL.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)
    multiqc_files = multiqc_files.mix(FASTQC.out.zip.map {m,z -> z})

    // trim adapters off reads
    CUTADAPT_WORKFLOW(
        TRACY_CONSENSUS.out.consensus,
        ch_primers
    )
    ch_versions = ch_versions.mix(CUTADAPT_WORKFLOW.out.versions)
    //ch_reporting = ch_reporting.mix(CUTADAPT_WORKFLOW.out.qc)

    // Assign taxonomy to sequence
    BLAST_TAXONOMY(
        CUTADAPT_WORKFLOW.out.trimmed,
        ch_blast_db.collect(),
        ch_tax_files.collect(),
        ch_taxdb.collect(),
        ch_blocklist.collect()
    )
    ch_reporting   = ch_reporting.mix(BLAST_TAXONOMY.out.composition, BLAST_TAXONOMY.out.composition_json, BLAST_TAXONOMY.out.filtered_blast, BLAST_TAXONOMY.out.consensus)
    // multiqc_files = multiqc_files.mix(BLAST_TAXONOMY.out.qc)
   
    CUSTOM_DUMPSOFTWAREVERSIONS(
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    multiqc_files = multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml)

    MULTIQC(
        multiqc_files.collect(),
        ch_multiqc_config,
        ch_multiqc_logo
    )

    // Compute reports
    REPORTING(
        ch_reporting,
        CUSTOM_DUMPSOFTWAREVERSIONS.out.yml,
        pipeline_info,
        ch_logo
    )

    emit:
    qc = MULTIQC.out.html
}

// Set the correct blast database or throw an error if unknown
def set_blast_db(database) {
    if (!params.references.databases.keySet().contains(database)) {
        log.warn "Provided an unknown database (--db ${database})\nPlease check valid options with --list_dbs\nExiting."
        System.exit(1)
    }
    def blast_db = file(params.references.databases[database].blast_db, checkIfExists: true)
    return blast_db
}

// turn the summaryMap to a JSON file
def dumpParametersToJSON(outdir) {
    
    params.version = workflow.manifest.version
    params.pipeline = workflow.manifest.name
    params.database_info = params.db ? params.references.databases[params.db].description : "user-provided"
    params.database_version = params.db ? params.references.databases[params.db].version : "user-provided"

    def filename  = "pipeline_settings.json"
    def temp_pf   = new File(workflow.launchDir.toString(), ".${filename}")
    def jsonStr   = groovy.json.JsonOutput.toJson(params)
    temp_pf.text  = groovy.json.JsonOutput.prettyPrint(jsonStr)

    nextflow.extension.FilesEx.copyTo(temp_pf.toPath(), "${outdir}/pipeline_info/pipeline_settings.json")
    temp_pf.delete()
    return file("${outdir}/pipeline_info/pipeline_settings.json")
}