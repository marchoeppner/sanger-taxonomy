# Usage information

[Basic execution](#basic-execution)

[Pipeline version](#specifying-pipeline-version)

[Basic options](#basic-options)

## Basic execution

Please see our [installation guide](installation.md) to learn how to set up this pipeline first. 

A basic execution of the pipeline looks as follows:

a) Without a site-specific config file

```bash
nextflow run marchoeppner/sanger-taxonomy -profile singularity --input samples.csv \\
--reference_base /path/to/references \\
--run_name pipeline-test
```

where `path_to_references` corresponds to the location in which you have [installed](installation.md) the pipeline references. 

In this example, the pipeline will assume it runs on a single computer with the singularity container engine available. Available options to provision software are:

`-profile singularity`

`-profile docker` 

`-profile podman` 

`-profile conda` 

Additional software provisioning tools as described [here](https://www.nextflow.io/docs/latest/container.html) may also work, but have not been tested by us. Please note that conda may not work for all packages on all platforms. If this turns out to be the case for you, please consider switching to one of the supported container engines. 

b) with a site-specific config file

```bash
nextflow run marchoeppner/sanger-taxonomy -profile lsh --input samples.csv \\
--run_name pipeline-test 
```

In this example, both `--reference_base` and the choice of software provisioning are already set in the local configuration `lsh` and don't have to be provided as command line argument. 

## Specifying pipeline version

If you are running this pipeline in a production setting, you will want to lock the pipeline to a specific version. This is natively supported through nextflow with the `-r` argument:

```bash
nextflow run marchoeppner/pipeline -profile lsh -r 1.0 <other options here>
```

The `-r` option specifies a github [release tag](https://github.com/marchoeppner/sanger-taxonomy/releases) or branch, so could also point to `main` for the very latest code release. Please note that every major release of this pipeline (1.0, 2.0 etc) comes with a new reference data set, which has the be [installed](installation.md) separately.

## Basic options

### `--input` [default = null ]

A sample list in TSV format, specifying a sample name and the associated ab1 files. 

```TSV
sample  fwd rev
mySample    /path/to/data_1.ab1 /path/to/data_2.ab1
```

### `--db` [ default = null ]

The database to perform searches against. For a full list of available options, see `--list_dbs`

### `--list_dbs`  [ default = false ]

Print a list of available databases to the screen. 

### Blast options

Changes in the following settings will affect the results you obtain from the respective database (increase or decrease stringency).

#### `--blocklist` [ default = null ]

Provide a list of NCBI taxonomy IDs (one per line) that should be masked from the BLAST database (and thus the result). This pipeline uses a built-in [block list](https://raw.githubusercontent.com/marchoeppner/sanger-taxonomy/main/assets/blocklist.txt) - but you can use this option to overwrite it, if need be. A typical use case would be a list of taxa that you know for a fact to be false positive hits (like extinct species). Consider merging your list with the built-in block list to make sure you mask previously identified problematic taxa. 

#### `--disable_low_complexity` [ default = false]

By default, Blast will filter low complexity sequences. If your amplicons have very low complexity, you may wish to set this option to disable the masking of low complexity motifs. This effectively deactivates the DUST filter and soft masking.

```bash
nextflow run marchoeppner/sanger-taxonomy
-profile apptainer \
--input samples.tsv \
--disable_low_complexity ...
```

#### `--blast_evalue` [ default = "1e-20" ]

Maximal e-value of BLAST results

#### `--blast_qcov` [ default = "100" ]

Amount of the query that has to be covered by a BLAST hit, in percent.

#### `--blast_perc_id` [ default = "97" ]

Minimal identity level between query and BLAST hit, in percent

#### `--blast_bitscore_diff` [ default = 4 ]

Maximal difference between the best BLAST hit's bitscore and the other hits to be kept.

#### `--blast_min_consensus` [ default = 0.51 ]

Minimal consensus level between all BLAST results for a given query to be assigned to a taxonomic node.
