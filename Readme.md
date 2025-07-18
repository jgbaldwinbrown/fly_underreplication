# Fly underreplication

This is a collection of scripts for RNAseq analysis of underreplicated regions of fly polytenes.

## General pipeline

The general structure of the analysis looks like this:

```
bowtie -> htseq -> combine (custom) -> deseq2
```

The bowtie and htseq components of the analysis are not here yet. The combining
script just puts together the results from htseq on each independent genotype
into one file, and then deseq2 does the main differential expression analysis.

## input files

The output of htseq is included here in directories named after the crosses,
with the structure `./[genotype]/[genotype]_htseq_out.txt.gz`. These are the inputs to the rest of the analysis.

## combine.sh and combine.go

combine.go takes the gzipped output of a bunch of runs of htseq (one per genotype) and combines them into one table. Run it like this:

```sh
go run combine.go <paths.txt > combined.txt
```

Where paths.txt is a newline-separated list of gzipped files to combine. combine.sh just runs combine.go on the included dataset.

## deseqscript\_clean.R

This script runs deseq2 with a few different combinations of genotypes. Take a
look at the first few lines of the 'minimal' function to get an idea of a
basic deseq2 run.

If you run this after running combine.sh, it should recapitulate my analysis.
