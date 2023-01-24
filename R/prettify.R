#' Prettify tokenized output
#'
#' @inherit audubon::prettify description return details
#' @inheritParams audubon::prettify
#' @importFrom audubon prettify
#' @export
prettify <- function(tbl,
                     into = get_dict_features("ipa"),
                     col_select = seq_along(into)) {
  audubon::prettify(tbl, into = into, col_select = col_select)
}

#' Get dictionary's features
#'
#' @inherit audubon::get_dict_features description return details seealso
#' @inheritParams audubon::get_dict_features
#' @importFrom audubon get_dict_features
#' @export
get_dict_features <- audubon::get_dict_features
