#' Mute tokens by condition
#'
#' Replaces tokens in the tidy text dataset with a string scalar
#' only if they are matched to an expression.
#'
#' @param tbl A tidy text dataset.
#' @param condition <[`data-masked`][rlang::args_data_masking]>
#' A logical expression.
#' @param .as String with which tokens are replaced
#' when they are matched to condition.
#' The default value is `NA_character`.
#' @returns A data.frame.
#' @export
mute_tokens <- function(tbl,
                        condition,
                        .as = NA_character_) {
  condition <- enquo(condition)
  dplyr::mutate(tbl, token = dplyr::if_else(!!condition, .as, .data$token))
}
