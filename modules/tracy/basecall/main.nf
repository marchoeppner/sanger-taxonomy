process TRACY_BASECALL {

    tag "${meta.sample_id}"

    label 'short_serial'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tracy:0.7.6--h0d5efe1_0' :
        'quay.io/biocontainers/tracy:0.7.6--h0d5efe1_0' }"

    input:
    tuple val(meta), path(traces)

    output:
    tuple val(meta), path('*.fastq'), emit: reads
    path('versions.yml'), emit: versions

    script:
    def args = task.ext.args ?: ''

    if (traces.size() > 1) {
        fwd = traces[0].getBaseName() + ".fastq"
        rev = traces[1].getBaseName() + ".fastq"
        """
        tracy basecall $args -o $fwd ${traces[0]}
        tracy basecall $args -o $rev ${traces[1]}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            Tracy: \$(tracy -v 2>&1 | head -n1 | sed -e "s/.*: v//g")
        END_VERSIONS
        """
    } else {
        fwd = traces[0].getBaseName() + ".fastq"
        """
        tracy basecall $args -o $fwd ${traces[0]}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            Tracy: \$(tracy -v 2>&1 | head -n1 | sed -e "s/.*: v//g")
        END_VERSIONS
        """
    }
    
}
