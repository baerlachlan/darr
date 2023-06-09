% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/countAlleles.R
\name{countAlleles}
\alias{countAlleles}
\alias{countAlleles,GRanges,list-method}
\title{Count alleles within each experimental group}
\usage{
countAlleles(genotypes, groups)

\S4method{countAlleles}{GRanges,list}(genotypes, groups)
}
\arguments{
\item{genotypes}{\code{GRanges} object with metadata columns containing genotype
information for all samples}

\item{groups}{Named \code{list} specifying the sample grouping structure, where
each element contains a character vector of sample names}
}
\value{
\code{GRangesList} containing a summary of allele counts at each range.
Each element of the list represents a distinct sample group
}
\description{
Summarise the alleles from genotype calls at each single
nucleotide locus within each sample group
}
\examples{
fl <- system.file("extdata", "chr1.vcf.bgz", package="darr")
genotypes <- readGenotypes(fl)
groups <- list(
    group1 = c("S2", "S7", "S9", "S10", "S19", "S20"),
    group2 = c("S3", "S6", "S11", "S12", "S15", "S16", "S18")
)
countAlleles(genotypes, groups)

}
