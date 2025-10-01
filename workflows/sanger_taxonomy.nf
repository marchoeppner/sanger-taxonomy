// Modules
include { INPUT_CHECK }                 from './../modules/input_check'
include { MULTIQC }                     from './../modules/multiqc'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './../modules/custom/dumpsoftwareversions'
include { TRACY_CONSENSUS }             from './../modules/tracy/consensus'
include { TRACY_BASECALL }              from './../modules/tracy/basecall'
include { FASTQC }                      from './../modules/fastqc'

include { BLAST_TAXONOMY }              from './../subworkflows/blast_taxonomy'

workflow SANGER_TAXONOMY {

    main:

    samplesheet =   params.input ? Channel.fromPath(params.input, checkIfExists: true) : Channel.value([])

    ch_multiqc_config = params.multiqc_config   ? Channel.fromPath(params.multiqc_config, checkIfExists: true).collect() : Channel.value([])
    ch_multiqc_logo   = params.multiqc_logo     ? Channel.fromPath(params.multiqc_logo, checkIfExists: true).collect() : Channel.value([])

    ch_versions = Channel.from([])
    multiqc_files = Channel.from([])

    if (params.input) {

        blast_db = set_blast_db(params.db)
        version  = params.references.databases[params.db].version

        if (params.reference_base) {
            tax_nodes           = file(params.references.taxonomy.nodes, checkIfExists: true)          // ncbi taxnomy node file
            tax_rankedlineage   = file(params.references.taxonomy.rankedlineage, checkIfExists: true)  // ncbi rankedlineage file
            tax_merged          = file(params.references.taxonomy.merged, checkIfExists: true)         // ncbi merged file
            ch_tax_files        = Channel.of([ tax_nodes, tax_rankedlineage, tax_merged ])
            ch_taxdb            = Channel.fromPath(params.references.taxonomy.taxdb, checkIfExists: true)
        }

        ch_blocklist = Channel.fromPath(params.blocklist, checkIfExists: true)

        Channel.fromPath(blast_db, checkIfExists: true).map { db ->
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
    ch_versions = ch_versions.mix(TRACY_CONSENSUS.out.versions)

        // Trace file base calling
    TRACY_BASECALL(
        INPUT_CHECK.out.traces
    )
    ch_versions = ch_versions.mix(TRACY_BASECALL.out.versions)

    TRACY_BASECALL.out.reads.view()

    //FASTQC(
    //    TRACY_BASECALL.out.reads
    //)
    //ch_versions = ch_versions.mix(FASTQC.out.versions)
    //multiqc_files = multiqc_files.mix(FASTQC.out.zip)

    // Assign taxonomy to sequence
    BLAST_TAXONOMY(
        TRACY_CONSENSUS.out.consensus,
        ch_blast_db.collect(),
        ch_tax_files.collect(),
        ch_taxdb.collect(),
        ch_blocklist.collect()
    )

    CUSTOM_DUMPSOFTWAREVERSIONS(
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    multiqc_files = multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml)

    MULTIQC(
        multiqc_files.collect(),
        ch_multiqc_config,
        ch_multiqc_logo
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