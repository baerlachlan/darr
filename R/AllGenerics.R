#' @name assignFeatureDar
#' @rdname assignFeatureDar-methods
#' @export
setGeneric(
    "assignFeatureDar",
    function(features, dar, darVal = c("origin", "region"))
        standardGeneric("assignFeatureDar")
)

#' @name convertRanges
#' @rdname convertRanges-methods
#' @export
setGeneric(
    "convertRanges",
    function(dar, extendEdges = FALSE) standardGeneric("convertRanges")
)

#' @name countAlleles
#' @rdname countAlleles-methods
#' @export
setGeneric(
    "countAlleles",
    function(genotypes, groups) standardGeneric("countAlleles")
)

#' @name countsToProps
#' @rdname countsToProps-methods
#' @export
setGeneric(
    "countsToProps",
    function(counts, filter = TRUE) standardGeneric("countsToProps")
)

#' @name dar
#' @rdname dar-methods
#' @export
setGeneric(
    "dar",
    function(props, contrasts, winSize = 5) standardGeneric("dar")
)

#' @name filterLoci
#' @rdname filterLoci-methods
#' @export
setGeneric(
    "filterLoci",
    function(counts, filter = n_called > n_missing)
        standardGeneric("filterLoci")
)

#' @name plotDarECDF
#' @rdname plotDarECDF-methods
#' @export
setGeneric(
    "plotDarECDF",
    function(dar, darVal = c("origin", "region"), highlight = NULL)
        standardGeneric("plotDarECDF")
)

#' @name readGenotypes
#' @rdname readGenotypes-methods
#' @export
setGeneric(
    "readGenotypes",
    function(file, unphase = TRUE, ...) standardGeneric("readGenotypes")
)

#' @name unphaseGT
#' @rdname unphaseGT-methods
#' @export
setGeneric(
    "unphaseGT",
    function(gt) standardGeneric("unphaseGT")
)
