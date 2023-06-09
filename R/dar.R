#' @title Calculate Differential Allelic Representation (DAR)
#'
#' @description Calculate DAR between two sample groups
#'
#' @details DAR is calculated as the Euclidean distance between the allelic
#' proportions (i.e. proportion of As, Cs, Gs and Ts) of two sample groups at
#' a single nucleotide locus, scaled such that all values range inclusively
#' between 0 and 1.
#' A DAR value of 0 represents identical allelic representation between the
#' two sample groups, while a DAR value of 1 represents complete diversity
#'
#' @param props `GRangesList` containing a summary of normalised allele counts
#' (i.e. as proportions) at each range.
#' Each element of the list represents a distinct sample group
#' @param contrasts Contrast `matrix` specifying which sample groups to
#' to calculate DAR between.
#' Each column must represent a single contrast, and rows represent the levels
#' (i.e. sample groups) to be contrasted.
#' The two levels involved with each contrast should be specified with
#' `1` and `-1`
#' @param winSize `integer(1)` specifying the number of ranges to include
#' in the elastic sliding window used for averaging DAR values within a region.
#' Must be an odd integer in order to incorporate the origin locus and an
#' equal number of loci either side
#'
#' @return `GRangesList` containing DAR values at each overlapping range
#' between the contrasted sample groups.
#' Two types of DAR values are reported in the metadata columns of each GRanges
#' object:
#'
#' - dar_origin: The raw DAR values calculated at single nucleotide positions
#' (the origin) between sample groups.
#' - dar_region: The mean of raw DAR values in a region surrounding the origin.
#' The size of the region is controlled using the `winSize` argument, which
#' establishes an elastic sliding window to average the specified number
#' of dar_origin values.
#'
#' Each element of the list represents a single contrast defined in the
#' input contrast matrix
#'
#' @examples
#' fl <- system.file("extdata", "chr1.vcf.bgz", package="darr")
#' genotypes <- readGenotypes(fl)
#' groups <- list(
#'     group1 = c("S2", "S7", "S9", "S10", "S19", "S20"),
#'     group2 = c("S3", "S6", "S11", "S12", "S15", "S16", "S18")
#' )
#' counts <- countAlleles(genotypes, groups)
#' props <- countsToProps(counts)
#' contrasts <- matrix(
#'     data = c(1, -1),
#'     dimnames = list(
#'         Levels = c("group1", "group2"),
#'         Contrasts = c("group1v2")
#'     )
#' )
#' dar(props, contrasts, winSize = 5)
#'
#' @import GenomicRanges
#' @importFrom S4Vectors endoapply mcols 'mcols<-' from to 'metadata<-'
#' @importFrom stats dist
#' @importFrom GenomeInfoDb seqnames 'seqlevels<-' seqlevelsInUse
#' @importFrom stats filter
#' @rdname dar-methods
#' @aliases dar
#' @export
setMethod(
    "dar",
    signature = signature(props = "GRangesList", contrasts = "matrix"),
    function(props, contrasts, winSize) {

        lvls <- dimnames(contrasts)[[1]]
        conts <- dimnames(contrasts)[[2]]
        if (any(is.null(lvls), is.null(conts)))
            stop("Dimnames of `contrasts` must be labelled")
        if (!all(lvls %in% names(props)))
            stop("Levels of `contrasts` must match names of `props`")
        contrasts <- .contrastsAsList(contrasts)
        if (winSize < 1 || winSize %% 2 != 1)
            stop("`winSize` must be an odd integer greater than 0")
        grl <- .calcDar(props = props, contrasts = contrasts)
        grl <- .smoothDar(dar = grl, winSize = winSize)
        grl

    }
)

#' @keywords internal
.contrastsAsList <- function(contrasts) {

    cols <- seq(ncol(contrasts))
    contrastsList <- lapply(cols, function(i){
        grp1 <- names(which(contrasts[,i] == 1))
        grp2 <- names(which(contrasts[,i] == -1))
        if (!all(length(grp1) == 1, length(grp2) == 1))
            stop("`contrasts` defined incorrectly")
        c(grp1, grp2)
    })
    names(contrastsList) <- colnames(contrasts)
    contrastsList

}

#' @keywords internal
.calcDar <- function(props, contrasts) {

    grl <- lapply(contrasts, function(x){
        ## Subset for groups to be contrasted
        props <- props[x]
        ## Subset for ranges present in both groups
        overlaps <- findOverlaps(props[[1]], props[[2]])
        props[[1]] <- props[[1]][from(overlaps),]
        props[[2]] <- props[[2]][to(overlaps),]
        stopifnot(identical(granges(props[[1]]), granges(props[[2]])))
        gr <- granges(props[[1]])
        props <- lapply(props, mcols)
        props <- lapply(props, as.matrix)
        ## Calculate Euclidean distance
        dist <- vapply(seq_along(gr), function(i){
            mat <- rbind(props[[1]][i,], props[[2]][i,])
            dist <- dist(mat, method = "euclidean")
            as.numeric(dist)
        }, numeric(1))
        ## Convert to DAR
        mcols(gr)$dar_origin <- dist / sqrt(2)
        ## Remove seqlevels that may be lost due to no overlap
        seqlevels(gr) <- seqlevelsInUse(gr)
        ## Add rangeType to metadata for downstream use
        metadata(gr)$rangeType <- "origin"
        gr
    })
    GRangesList(grl)

}

#' @keywords internal
.smoothDar <- function(dar, winSize) {

    endoapply(dar, function(x){
        ## Add winSize to metadata for downstream use
        metadata(x)$winSize <- winSize
        grl <- split(x, f = seqnames(x))
        grl <- endoapply(grl, function(y){
            ## Throw a more informative error than filter() would
            if (winSize > NROW(y))
                stop(
                    "`winSize` greater than number of ranges for seqname ",
                    unique(seqnames(y)), call. = FALSE
                )
            mcols(y)$dar_region <- filter(
                y$dar_origin, rep(1 / winSize, winSize), sides = 2
            )
            mcols(y)$dar_region <- as.numeric(mcols(y)$dar_region)
            y
        })
        unlist(grl, use.names = FALSE)
    })

}
