#' Tokenize sentences using 'Vibrato'
#'
#' @param x A data.frame like object or a character vector to be tokenized.
#' @param text_field String or symbol; column name where to get texts to be tokenized.
#' @param docid_field String or symbol; column name where to get identifiers of texts.
#' @param sys_dic Character scalar; path to the system dictionary for 'Vibrato'.
#' @param user_dic Character scalar; path to the user dictionary for 'Vibrato'.
#' @param split Logical. If passed as `TRUE`, the function internally splits the sentence
#' into sub-sentences using \code{stringi::stri_split_boundaries(type = "sentence")}.
#' @param mode Character scalar to switch output format.
#' @return A tibble or a named list of tokens.
#' @export
tokenize <- function(x,
                     text_field = "text",
                     docid_field = "doc_id",
                     sys_dic = "",
                     user_dic = "",
                     split = FALSE,
                     mode = c("parse", "wakati")) {
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
      "i" = "Download the dictionary file using `download_dict()` at first."
    ))
  }
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  text_field <- enquo(text_field)
  docid_field <- enquo(docid_field)

  sentence <-
    purrr::set_names(
      dplyr::pull(x, {{ text_field }}) %>% stringi::stri_enc_toutf8(),
      dplyr::pull(x, {{ docid_field }})
    )

  tbl <- tagger_impl(sentence, sys_dic, user_dic, split)

  # if it's a factor, preserve ordering
  col_names <- rlang::as_name(docid_field)
  if (is.factor(x[[col_names]])) {
    col_u <- levels(x[[col_names]])
  } else {
    col_u <- unique(x[[col_names]])
  }

  tbl <- x |>
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
      "i" = "Download the dictionary file using `download_dict()` at first."
    ))
  }
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  nm <- names(x)
  if (is.null(nm)) {
    nm <- seq_along(x)
  }
  x <- stringi::stri_enc_toutf8(x) %>%
    purrr::set_names(nm)

  tbl <- tagger_impl(x, sys_dic, user_dic, split) %>%
    dplyr::as_tibble()

  if (!identical(mode, "wakati")) {
    return(tbl)
  }
  as_tokens(tbl, pos_field = NULL)
}

#' @noRd
tagger_impl <- function(sentence, sys_dic, user_dic, split) {
  if (isTRUE(split)) {
    res <-
      purrr::imap(sentence, function(vec, doc_id) {
        vec <- stringi::stri_split_boundaries(vec, type = "sentence") %>%
          unlist()
        dplyr::bind_cols(
          data.frame(doc_id = doc_id),
          vbrt(vec, sys_dic = path.expand(sys_dic), user_dic = path.expand(user_dic))
        ) %>%
          dplyr::mutate(
            sentence_id = .data$sentence_id + 1,
            token_id = .data$token_id + 1
          )
      }) %>%
      purrr::list_rbind()
  } else {
    res <-
      vbrt(sentence, sys_dic = path.expand(sys_dic), user_dic = path.expand(user_dic)) %>%
      dplyr::mutate(
        sentence_id = .data$sentence_id + 1,
        token_id = .data$token_id + 1
      ) %>%
      dplyr::left_join(
        data.frame(
          sentence_id = seq_along(sentence),
          doc_id = names(sentence)
        ),
        by = "sentence_id"
      ) %>%
      dplyr::relocate("doc_id", dplyr::everything())
  }
  res %>%
    dplyr::mutate(
      doc_id = factor(.data$doc_id, unique(.data$doc_id)),
      sentence_id = as.integer(.data$sentence_id),
      token_id = as.integer(.data$token_id)
    )
}
