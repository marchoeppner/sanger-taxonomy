# Sanger-taxonomy

This pipeline takes Sanger ab1 files (forward, reverse) from amplicon sequencing, computes a consensus and compares that consensus against a database to determine the most probable species that sequence came from. A common use is in food authentication. The taxonomic assignment uses BLAST, combined with a weighting process to derive a consensus call among the highest scoring hits. Users can choose from several databases to compare against, based on the gene that was amplified (e.g. large ribosomal subunit RNA, CytB, COX1, etc.). The pipeline and its reference data are fully versioned and reproducible. 


## Documentation 

1. [What happens in this pipeline?](docs/pipeline.md)
2. [Installation and configuration](docs/installation.md)
3. [Running the pipeline](docs/usage.md)
4. [Output](docs/output.md)
5. [Software](docs/software.md)
5. [Troubleshooting](docs/troubleshooting.md)
6. [Developer guide](docs/developer.md)
