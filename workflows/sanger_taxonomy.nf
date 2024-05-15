// Modules
include { INPUT_CHECK }                 from './../modules/input_check'
include { MULTIQC }                     from './../modules/multiqc'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './../modules/custom/dumpsoftwareversions'
include { TRACY_CONSENSUS }             from './../modules/tracy/consensus'
include { TRACY_BASECALL }              from './../modules/tracy/basecall'
include { FASTQC }                      from './../modules/fastqc'

ch_multiqc_config = params.multiqc_config   ? Channel.fromPath(params.multiqc_config, checkIfExists: true).collect() : Channel.value([])
ch_multiqc_logo   = params.multiqc_logo     ? Channel.fromPath(params.multiqc_logo, checkIfExists: true).collect() : Channel.value([])

ch_versions = Channel.from([])
multiqc_files = Channel.from([])

ch_blastdb = Channel.fromPath("${params.blast_db}*")

tools = params.tools ? params.tools.split(',').collect { it.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '') } : []

// The taxonomy database for this gene
if (params.reference_base && gene) {
    ch_db_sintax            = Channel.fromPath(params.references.genes[gene].sintax_db, checkIfExists: true).collect()
} else if (gene) {
    ch_db_sintax            = Channel.fromPath(file(params.references.genes[gene].sintax_url)).collect()
}

workflow SANGER_TAXONOMY {
    take:
    samplesheet

    main:

    INPUT_CHECK(samplesheet)

    TRACY_CONSENSUS(
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(TRACY_CONSENSUS.out.versions)

    TRACY_BASECALL(
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(TRACY_BASECALL.out.versions)

    FASTQC(
        TRACY_BASECALL.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)
    multiqc_files = multiqc_files.mix(FASTQC.out.zip)

    if ('sintax' in tools ) {
        VSEARCH_SINTAX(
            TRACY_CONSENSUS.out.consensus,
            sintax_db
        )
        ch_versions = ch_versions.mix(VSEARCH_SINTAX.out.versions)
    }
    
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
