#' Tokenize sentences using 'Vibrato'
#'
#' @param x A data.frame like object or a character vector to be tokenized.
#' @param text_field <[`data-masked`][rlang::args_data_masking]>
#' String or symbol; column containing texts to be tokenized.
#' @param docid_field <[`data-masked`][rlang::args_data_masking]>
#' String or symbol; column containing document IDs.
#' @param sys_dic Character scalar; path to the system dictionary for 'Vibrato'.
#' @param user_dic Character scalar; path to the user dictionary for 'Vibrato'.
#' @param split split Logical. When passed as `TRUE`, the function
#' internally splits the sentences into sub-sentences
#' @param mode Character scalar to switch output format.
#' @returns A tibble or a named list of tokens.
#' @export
tokenize <- function(x,
                     text_field = "text",
                     docid_field = "doc_id",
                     sys_dic = "",
                     user_dic = "",
                     split = FALSE,
                     mode = c("parse", "wakati")) {
  # TODO: option to omit debug information
  UseMethod("tokenize", x)
}

#' @export
tokenize.default <- function(x,
                             text_field = "text",
                             docid_field = "doc_id",
                             sys_dic = "",
                             user_dic = "",
                             split = FALSE,
                             mode = c("parse", "wakati")) {
  if (!file.exists(sys_dic)) {
    rlang::abort(c(
      "`sys_dic` is not found.",
      "i" = "Download the dictionary file at first."
    ))
  }
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  text_field <- enquo(text_field)
  docid_field <- enquo(docid_field)

  x <- dplyr::as_tibble(x)

  tbl <- tagger_impl(
    dplyr::pull(x, {{ text_field }}),
    dplyr::pull(x, {{ docid_field }}),
    sys_dic,
    user_dic,
    split
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
    ) %>%
    dplyr::as_tibble()
  if (!identical(mode, "wakati")) {
    return(tbl)
  }
  as_tokens(tbl, pos_field = NULL)
}


#' @export
tokenize.character <- function(x,
                               text_field = "text",
                               docid_field = "doc_id",
                               sys_dic = "",
                               user_dic = "",
                               split = FALSE,
                               mode = c("parse", "wakati")) {
  if (!file.exists(sys_dic)) {
    rlang::abort(c(
      "`sys_dic` is not found.",
      "i" = "Download the dictionary file at first."
    ))
  }
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  nm <- names(x)
  if (is.null(nm)) {
    nm <- seq_along(x)
  }
  tbl <- tagger_impl(x, nm, sys_dic, user_dic, split)

  if (!identical(mode, "wakati")) {
    return(tbl)
  }
  as_tokens(tbl, pos_field = NULL)
}

#' @noRd
#' @param sentence A character vector to be tokenized.
#' @param sys_dic Character scalar; path to the system dictionary for 'Vibrato'.
#' @param user_dic Character scalar; path to the user dictionary for 'Vibrato'.
#' @returns A tibble.
vbrt_tagger <- function(sentence, sys_dic, user_dic) {
  vbrt(sentence, sys_dic = path.expand(sys_dic), user_dic = path.expand(user_dic)) %>%
    dplyr::as_tibble()
}

#' @noRd
#' @param sentence A character vector to be tokenized.
#' @param docnames A character vector that indicates document names.
#' @param sys_dic Character scalar; path to the system dictionary for 'Vibrato'.
#' @param user_dic Character scalar; path to the user dictionary for 'Vibrato'.
#' @param split Logical.
tagger_impl <- function(sentence, docnames, sys_dic, user_dic, split) {
  if (isTRUE(split)) {
    res <-
      stringi::stri_split_boundaries(sentence, type = "sentence") %>%
      rlang::as_function(~ {
        sizes <- lengths(.)
        dplyr::left_join(
          vbrt_tagger(unlist(., use.names = FALSE), sys_dic, user_dic),
          data.frame(
            doc_id = rep(docnames, sizes),
            sentence_id = seq_len(sum(sizes)) - 1
          ),
          by = "sentence_id"
        )
      })() %>%
      dplyr::mutate(token_id = .data$token_id + 1) %>%
      dplyr::mutate(sentence_id = dplyr::consecutive_id(.data$sentence_id), .by = "doc_id")
  } else {
    res <-
      vbrt_tagger(sentence, sys_dic, user_dic) %>%
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
