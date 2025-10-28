# Sanger-taxonomy

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.04.2-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with apptainer](https://img.shields.io/badge/apptainer-run?logo=apptainer&logoColor=3EB049&label=run%20with&labelColor=000000)](https://apptainer.org/)

This pipeline takes Sanger ab1 files (forward, reverse) from amplicon sequencing, computes a consensus and compares that consensus against a database to determine the most probable species that sequence came from. A common use is in food authentication. The taxonomic assignment uses BLAST, combined with a weighting process to derive a consensus call among the highest scoring hits. Users can choose from several databases to compare against, based on the gene that was amplified (e.g. large ribosomal subunit RNA, CytB, COX1, etc.). The pipeline and its reference data are fully versioned and reproducible. 

Sanger-taxonomy was build from concepts and code developed for [FooDMe2](https://github.com/bio-raum/FooDMe2).

## Documentation 

1. [What happens in this pipeline?](docs/pipeline.md)
2. [Installation and configuration](docs/installation.md)
3. [Running the pipeline](docs/usage.md)
4. [Output](docs/output.md)
5. [Software](docs/software.md)
5. [Troubleshooting](docs/troubleshooting.md)
6. [Developer guide](docs/developer.md)
