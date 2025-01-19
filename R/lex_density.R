#' Calculate lexical density
#'
#' The lexical density is the proportion of content words (lexical items)
#' in documents. This function is a simple helper for calculating
#' the lexical density of given datasets.
#'
#' @param vec A character vector.
#' @param contents_words A character vector containing values
#' to be counted as contents words.
#' @param targets A character vector with which
#' the denominator of lexical density is filtered before computing values.
#' @param negate A logical vector of which length is 2.
#' If passed as `TRUE`, then respectively negates the predicate functions
#' for counting contents words or targets.
#' @returns A numeric vector.
#' @export
lex_density <- function(vec,
                        contents_words,
                        targets = NULL,
                        negate = c(FALSE, FALSE)) {
  if (!rlang::has_length(negate, 2L)) {
    rlang::abort("The negate must have just 2 elements.")
  }

  if (isTRUE(negate[1])) {
    num_of_contents <- length(subset(vec, !vec %in% contents_words))
  } else {
    num_of_contents <- length(subset(vec, vec %in% contents_words))
  }
  if (!is.null(targets)) {
    if (isTRUE(negate[2])) {
      vec <- subset(vec, !vec %in% targets)
    } else {
      vec <- subset(vec, vec %in% targets)
    }
  }
  num_of_totals <- length(vec)

  num_of_contents / num_of_totals
}
