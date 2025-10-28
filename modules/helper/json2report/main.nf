process HELPER_JSON2REPORT {
    tag "$meta.sample_id"
    label 'short_serial'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cnvkit:0.9.12--pyhdfd78af_1' :
        'quay.io/biocontainers/cnvkit:0.9.12--pyhdfd78af_1' }"

    input:
    tuple val(meta), path(json)
    path(logo)

    output:
    tuple val(meta), path('*.pdf'), emit: pdf
    path 'versions.yml'    , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: meta.sample_id

    """
    json2report_v2.py --json $json \\
    --report ${meta.report} \\
    --logo $logo \\
    $args \\
    --output ${prefix}.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version  | sed -e "s/Python //")
    END_VERSIONS
    """
}
