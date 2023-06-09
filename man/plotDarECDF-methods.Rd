% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/plotDarECDF.R
\name{plotDarECDF}
\alias{plotDarECDF}
\alias{plotDarECDF,GRanges-method}
\title{Plot the Empirical Cumulative Distribution Function of DAR}
\usage{
plotDarECDF(dar, darVal = c("origin", "region"), highlight = NULL)

\S4method{plotDarECDF}{GRanges}(dar, darVal = c("origin", "region"), highlight = NULL)
}
\arguments{
\item{dar}{\code{GRanges} object with metadata columns containing the desired
DAR values to plot}

\item{darVal}{\code{character(1)} specifying the whether to plot dar_origin or
dar_region values.
Options are "origin" and "region"}

\item{highlight}{\code{character(1)} specifying the chromosome to highlight with
a different colour}
}
\value{
A ggplot2 object
}
\description{
Plot the ECDF of DAR for each chromosome
}
\examples{
set.seed(230704)
gr <- GRanges(
    paste0(rep(seq(1,25), each = 100), ":", seq(1,100)),
    dar_origin = runif(2500, 0, 1)
)
## No highlighting, all chromosomes will be given individual colours
plotDarECDF(gr, darVal = "origin") +
theme_bw()

## With highlighting
plotDarECDF(gr, darVal = "origin", highlight = "25") +
scale_colour_manual(values = c("red", "grey")) +
theme_bw()

}
