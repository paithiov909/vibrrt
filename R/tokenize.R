#' @noRd
tagger_inner <- function(sentence, sys_dic, user_dic, max_grouping_len, verbose) {
  ret <- vbrt(sentence, sys_dic, user_dic, max_grouping_len) %>%
    dplyr::as_tibble()

  to_omit <- if (verbose) 0 else 4
  dplyr::select(ret, 1:dplyr::last_col(to_omit))
}

#' Wrapper that takes a tagger function
#'
#' @param sentence A character vector to be tokenized.
#' @param docnames A character vector that indicates document names.
#' @param split Logical.
#' @param tagger A tagger function created by [create_tagger()].
#' @returns A tibble.
#' @noRd
tagger_impl <- function(sentence, docnames, split, tagger) {
  if (isTRUE(split)) {
    res <-
      stringi::stri_split_boundaries(sentence, type = "sentence") %>%
      rlang::as_function(~ {
        sizes <- lengths(.)
        dplyr::left_join(
          tagger(unlist(., use.names = FALSE)),
          data.frame(
            doc_id = rep(docnames, sizes),
            sentence_id = seq_len(sum(sizes)) - 1
          ),
          by = "sentence_id"
        )
      })() %>%
      dplyr::mutate(token_id = .data$token_id + 1) %>%
      dplyr::mutate(
        sentence_id = dplyr::consecutive_id(.data$sentence_id),
        .by = "doc_id"
      )
  } else {
    res <-
      tagger(sentence) %>%
      dplyr::mutate(
        sentence_id = .data$sentence_id + 1,
        token_id = .data$token_id + 1
      ) %>%
      dplyr::left_join(
        data.frame(
          sentence_id = seq_along(sentence),
          doc_id = docnames
        ),
        by = "sentence_id"
      )
  }
  res %>%
    dplyr::mutate(doc_id = factor(.data$doc_id, unique(.data$doc_id))) %>%
    dplyr::relocate("doc_id", dplyr::everything())
}

#' Create a tagger function
#'
#' @param sys_dic Character scalar; path to the system dictionary for 'vibrato'.
#' @param user_dic Character scalar; path to the user dictionary for 'vibrato'.
#' @param max_grouping_len Integer scalar;
#' The maximum grouping length for unknown words.
#' The default value is `0L`, indicating the infinity length.
#' @param verbose Logical.
#' If `TRUE`, returns additional information for debugging.
#' @returns A function inheriting class `purrr_function_partial`.
#' @export
create_tagger <- function(sys_dic,
                          user_dic = "",
                          max_grouping_len = 0L,
                          verbose = FALSE) {
  if (!file.exists(sys_dic)) {
    rlang::abort(c(
      "`sys_dic` is not found.",
      "i" = "Download the dictionary file at first."
    ))
  }
  purrr::partial(
    tagger_inner,
    sys_dic = path.expand(sys_dic),
    user_dic = path.expand(user_dic),
    max_grouping_len = as.integer(max_grouping_len),
    verbose = verbose
  )
}

#' Tokenize sentences using a tagger
#'
#' @param x A data.frame like object or a character vector to be tokenized.
#' @param text_field <[`data-masked`][rlang::args_data_masking]>
#' String or symbol; column containing texts to be tokenized.
#' @param docid_field <[`data-masked`][rlang::args_data_masking]>
#' String or symbol; column containing document IDs.
#' @param split split Logical. When passed as `TRUE`, the function
#' internally splits the sentences into sub-sentences
#' @param mode Character scalar to switch output format.
#' @param tagger A tagger function created by [create_tagger()].
#' @returns A tibble or a named list of tokens.
#' @export
tokenize <- function(x,
                     text_field = "text",
                     docid_field = "doc_id",
                     split = FALSE,
                     mode = c("parse", "wakati"),
                     tagger) {
  UseMethod("tokenize", x)
}

#' @export
tokenize.default <- function(x,
                             text_field = "text",
                             docid_field = "doc_id",
                             split = FALSE,
                             mode = c("parse", "wakati"),
                             tagger) {
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  text_field <- enquo(text_field)
  docid_field <- enquo(docid_field)

  x <- dplyr::as_tibble(x)

  tbl <- tagger_impl(
    dplyr::pull(x, {{ text_field }}),
    dplyr::pull(x, {{ docid_field }}),
    split, tagger
  )

  # if it's a factor, preserve ordering
  col_names <- rlang::as_name(docid_field)
  if (is.factor(x[[col_names]])) {
    col_u <- levels(x[[col_names]])
  } else {
    col_u <- unique(x[[col_names]])
  }

  tbl <- x %>%
    dplyr::select(-!!text_field) %>%
    dplyr::mutate(dplyr::across(!!docid_field, ~ factor(., col_u))) %>%
    dplyr::rename(doc_id = {{ docid_field }}) %>%
    dplyr::left_join(
      tbl,
      by = c("doc_id" = "doc_id")
    )
  if (!identical(mode, "wakati")) {
    return(tbl)
  }
  as_tokens(tbl, pos_field = NULL)
}

#' @export
tokenize.character <- function(x,
                               text_field = "text",
                               docid_field = "doc_id",
                               split = FALSE,
                               mode = c("parse", "wakati"),
                               tagger) {
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  nm <- names(x)
  if (is.null(nm)) {
    nm <- seq_along(x)
  }
  tbl <- tagger_impl(x, nm, split, tagger)

  if (!identical(mode, "wakati")) {
    return(tbl)
  }
  as_tokens(tbl, pos_field = NULL)
}
