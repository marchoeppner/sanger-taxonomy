process TRACY_CONSENSUS {

    tag "${meta.sample_id}"

    label 'short_serial'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tracy:0.7.6--h0d5efe1_0' :
        'quay.io/biocontainers/tracy:0.7.6--h0d5efe1_0' }"

    input:
    tuple val(meta), path(traces)

    output:
    tuple val(meta), path('*consensus.fa'), emit: consensus
    path('versions.yml'), emit: versions

    script:

    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: meta.sample_id
    def result = prefix + ".consensus"
    """
    tracy consensus $args -o $result -b $prefix $traces

    sed -i.bak '/^>/s/\$/;size=1/' ${prefix}.consensus.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Tracy: \$(tracy -v 2>&1 | head -n1 | sed -e "s/.*: v//g")
    END_VERSIONS
    """
}
