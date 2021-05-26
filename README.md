# nf-LO
## Nextflow LiftOver pipeline
*nf-LO* is a [nextflow](https://www.nextflow.io/) workflow for generating genome alignment files compatible with the UCSC [liftOver](https://genome.ucsc.edu/cgi-bin/hgLiftOver) utility for converting genomic coordinates between assemblies. It can automatically pull genomes directly from NCBI or iGenomes (or the user can provide fasta files) and supports four different aligners ([lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz), [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/), [minimap2](https://github.com/lh3/minimap2), [GSAlign](https://github.com/hsinnan75/GSAlign)). Together these provide solutions for both different-species (lastz and minimap2) as well as same-species alignments (blat and GSAlign), with both standard and ultra-fast algorithms from a source to a target genome. It comes with a series of presets, allowing alignments of genomes depending on their genomic distance (near, medium and far). 

## Step-by-step tutorial
You can find more details on the usage of *nf-LO* in the [wiki page](https://github.com/evotools/nf-LO/wiki), including a simple step-by-step tutorial to run the analyses on your own genomes.

## Table of Contents

- [Installation](#Installation)
- [Quick start](#Quick-start)
- [Profiles](#Profiles)
- [Inputs](#Inputs)
  - [Custom fasta](#Custom-fasta)
  - [Download from NCBI](#Download-from-NCBI)
  - [Download from iGenomes](#Download-from-iGenomes)
- [Customize the run](#Customize-the-run)
- [Resources](#Resources) 
- [Example](#Example)
- [Citing](#Citing-nf-LO)
- [References](#References)

## Installation
Nextflow first needs to be installed. 
To do so, follow the instructions [here](https://www.nextflow.io/)
```
curl -s https://get.nextflow.io | bash
```
Note Nextflow requires Java 8 or later.
We suggest to install, depending on your preferences:
 - [anaconda](https://www.anaconda.com/products/individual)
 - [docker](https://www.docker.com/)
 - [singularity](https://sylabs.io/)

The workflow natively support four different ways to provide dependencies:
1. Anaconda: this is the recommended and easiest way.
2. Docker: you can create a docker image locally by using the `Dockerfile` and `environment.yml` files in the folder
3. Singularity: you can create a singularity sif image locally by using the `singularity.def` and `environment.yml` files in the folder
4. Local installation: we provide an `install.sh` script that will take care of installing all the dependencies.
If you need further information on the installation of the dependencies, you can have a look at the specific [wiki page](https://github.com/evotools/nf-LO/wiki/Installation)

## Quick start
Then, run the nf-LO workflow to align the S. cerevisiae and S. pombe genomes pulled directly from [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html):
```
./nextflow run evotools/nf-LO --igenome_target sacCer3 --igenome_source EF2 --distance far --aligner minimap2 -profile conda -latest --outdir ./my_liftover_minimap2
```
This command will use singularity to obtain the required dependencies and output a chain file compatible with the liftOver utility to the my_liftover_minmap2 folder. See below for more information on how to alternatively use docker, or to manually install the required tools.

## Profiles
*nf-LO* comes with a series of pre-defined profiles:
 - standard: this profile runs all dependencies in docker and other basic presets to facilitate the use
 - local: runs using local exe instead of containerized/conda dependencies (see manual installation for further details)
 - conda: runs the dependencies within conda
 - uge: runs using UGE scheduling system
 - sge: runs using SGE scheduling system
 - Additional profiles: see additional profiles supported [here](http://www.github.com/nf-core/configs)

## Inputs

There are three different ways a user can specify genomes to align. Note in each case the source genome is the genome of origin, from which you which to lift the positions. The target genome is the genome *to* which you wish to lift the positions to. 
We recommend to use soft-masked genomes to reduce the computation time for aligners such as lastz. 

### Custom fasta
The source and target genomes can be specified as local or remote (un)compressed fasta files using the `--source` and `--target` flags. 
### Download from NCBI
*nf-LO* can download fasta files from ncbi directly. Users provide a GCA/GCF code using the `--ncbi_source` and `--ncbi_target` flags as follow:
```
nextflow run evotools/nf-LO --ncbi_source GCF_001549955.1 --ncbi_target GCF_011751205.1 -profile local,test
```
### Download from iGenomes
*nf-LO* can also download genomes from the [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html) site. To do this users provide a genome identifier with the `--igenome_source` and `--igenome_target` flags as follow:
```
nextflow run evotools/nf-LO --igenome_source equCab2 --target igenome_dm6 -profile local,test
```

Note it is possible to mix source and target flags. For example using `--igenome_source` with `--ncbi_target`.

## Customize the run 
The workflow will provide some custom configuration for the different algorithms and distances. 
**NOTE**: the alignment stage heavily affects the results of the chaining process, so we strongly recommend to perform different tests with different configurations, including custom ones.
To see the presets available and how to fine-tune the pipeline go to our [Alignments](https://github.com/evotools/nf-LO/wiki/Alignments) wiki page.
The chain/net generation can also be fine-tuned to achieve better results (see [Chain/Netting](https://github.com/evotools/nf-LO/wiki/Chain-Netting)).

## Resources
If you're running the workflow in a local workstation, single node or a local server we recommend to define the maximum amount of cores and memory for each job.
You can set that using the `--max_memory NCPU` and `--max_cpus 'MEM.GB'`, where NCPU is the maximum number of cpus per task and MEM is maximum amount of memory for a single task.

## Example
To test the pipeline locally, simply run:
```
nextflow run evotools/nf-LO -profile test,conda
```
This will download and run the pipeline on the two toy genomes provided and generate liftover files. If you have all dependencies installed locally
you can omit ```conda``` from the profile configuration.

Alternatively, you can run it on your own genomes using a command like this:
```
nextflow run evotools/nf-LO \
    --source genome1 \
    --target genome2 \
    --annotation myfile.gff \
    --annotation_format gff \
    --distance near \
    --aligner lastz \
    --tgtSize 10000000 \
    --tgtOvlp 100000 \
    --srcSize 20000000 \
    --liftover_algorithm crossmap \
    --outdir ./my_liftover \
    --publish_dir_mode copy \
    --max_cpus 8 \
    --max_memory 32.GB \
    -profile conda 
```
This analysis will run using genome1 and genome2 as source and target, respectively. The source genome will be fragmented in chunks of 20Mb, 
whereas the target will be fragmented in 10Mb chunks overlapping 100Kb. It will use lastz as the aligner using the preset for closely related genomes (near).
The output files will be copied into the folder my_liftover.

## Citing nf-LO
To cite nf-LO, refer to:
```
nf-LO: A scalable, containerised workflow for genome-to-genome lift over
Andrea Talenti, James Prendergast
bioRxiv 2021.05.25.445595; doi: https://doi.org/10.1101/2021.05.25.445595
```

## References
Adaptive seeds tame genomic sequence comparison. Kiełbasa SM, Wan R, Sato K, Horton P, Frith MC. Genome Res. 2011 21(3):487-93; http://dx.doi.org/10.1101/gr.113985.110

Harris, R.S. (2007) Improved pairwise alignment of genomic DNA. Ph.D. Thesis, The Pennsylvania State University

Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100. http://dx.doi.org/10.1093/bioinformatics/bty191

Kent WJ. BLAT - the BLAST-like alignment tool. Genome Res. 2002 Apr;12(4):656-64

Zhao, H., Sun, Z., Wang, J., Huang, H., Kocher, J.-P., & Wang, L. (2013). CrossMap: a versatile tool for coordinate conversion between genome assemblies. Bioinformatics (Oxford, England), btt730

Lin, HN., Hsu, WL. GSAlign: an efficient sequence alignment tool for intra-species genomes. BMC Genomics 21, 182 (2020). https://doi.org/10.1186/s12864-020-6569-1
