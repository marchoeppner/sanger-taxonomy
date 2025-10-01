//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    samplesheet
        .splitCsv(header:true, sep:'\t')
        .map { row -> trace_channel(row) }
        .set { traces }

    emit:
    traces // channel: [ val(meta), [ reads ] ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def trace_channel(LinkedHashMap row) {
    def meta = [:]
    meta.sample_id    = row.sample
    meta.report       = row.report ? row.report : row.sample

    def array = []
    if (!file(row.fwd).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Forward trace does not exist!\n${row.fwd}"
    }
    if (row.rev) {
        if (!file(row.rev).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Reverse trace does not exist!\n${row.rev}"
        }
        array = [ meta, [ file(row.fwd), file(row.rev) ] ]
    } else {
            array = [ meta, [ file(row.fwd) ] ]
    }

    return array
}
