#' Tokenize sentence for character vector
#'
#' @param sentence Character vector to be tokenized.
#' @param sys_dic Character scalar; path to the system dictionary for mecab.
#' Note that the system dictionary is expected to be compiled with UTF-8,
#' not Shift-JIS or other encodings.
#' @param user_dic Character scalar; path to the user dictionary for mecab.
#' @param split Logical. If supplied `TRUE`, the function internally splits the sentence
#' into sub-sentences using \code{stringi::stri_split_boudaries(type = "sentence")}.
#' @param mode Character scalar to switch output format.
#' @return data.frame or named list.
#' @export
#' @examples
#' \dontrun{
#' df <- tokenize_vec("\u3053\u3093\u306b\u3061\u306f")
#' head(df)
#' }
tokenize_vec <- function(sentence,
                         sys_dic = system.file("dict/ipadic-mecab-2_7_0/system.dic", package = "vibrrt"),
                         user_dic = "",
                         split = FALSE,
                         mode = c("parse", "wakati")) {
  mode <- rlang::arg_match(mode, c("parse", "wakati"))

  # keep names
  nm <- names(sentence)
  if (is.null(nm)) {
    nm <- seq_along(sentence)
  }
  sentence <- stringi::stri_enc_toutf8(sentence) %>%
    purrr::set_names(nm)

  sys_dic <- stringi::stri_c(sys_dic, collapse = "")
  user_dic <- stringi::stri_c(user_dic, collapse = "")

  result <- tagger_impl(sentence, sys_dic, split)

  if (identical(mode, "wakati")) {
    result <- result %>%
      dplyr::group_by(.data$doc_id) %>%
      dplyr::group_map(~ .x$token) %>%
      purrr::set_names(nm)
  }
  return(result)
}

#' Tokenize sentence for data.frame
#'
#' @param tbl A data.frame.
#' @param text_field String or symbol; column name where to get texts to be tokenized.
#' @param docid_field String or symbol; column name where to get identifiers of texts.
#' @inheritParams tokenize_vec
#' @return data.frame.
#' @export
#' @examples
#' \dontrun{
#' df <- tokenize(
#'   data.frame(
#'     doc_id = seq_along(audubon::polano[5:8]),
#'     text = audubon::polano[5:8]
#'   )
#' )
#' head(df)
#' }
tokenize <- function(tbl,
                     text_field = "text",
                     docid_field = "doc_id",
                     sys_dic = system.file("dict/ipadic-mecab-2_7_0/system.dic", package = "vibrrt"),
                     split = FALSE) {
  text_field <- enquo(text_field)
  docid_field <- enquo(docid_field)

  sentence <-
    purrr::set_names(
      dplyr::pull(tbl, {{ text_field }}) %>% stringi::stri_enc_toutf8(),
      dplyr::pull(tbl, {{ docid_field }})
    )

  result <- tagger_impl(sentence, sys_dic, split)

  # if it's a factor, preserve ordering
  col_names <- rlang::as_name(docid_field)
  if (is.factor(tbl[[col_names]])) {
    col_u <- levels(tbl[[col_names]])
  } else {
    col_u <- unique(tbl[[col_names]])
  }

  tbl %>%
    dplyr::select(-!!text_field) %>%
    dplyr::mutate(dplyr::across(!!docid_field, ~ factor(., col_u))) %>%
    dplyr::rename(doc_id = {{ docid_field }}) %>%
    dplyr::left_join(
      result,
      by = c("doc_id" = "doc_id")
    )
}

#' @noRd
#' @import rlang
#' @importFrom dplyr %>%
tagger_impl <- function(sentence, sys_dic, split) {
  if (isTRUE(split)) {
    res <-
      purrr::imap_dfr(sentence, function(vec, doc_id) {
        vec <- stringi::stri_split_boundaries(vec, type = "sentence") %>%
          unlist()
        dplyr::bind_cols(
          data.frame(doc_id = doc_id),
          vbrt(vec, dict = sys_dic)
        ) %>%
          dplyr::mutate(sentence_id = .data$sentence_id + 1)
      })
  } else {
    res <-
      vbrt(sentence, dict = sys_dic) %>%
      dplyr::mutate(sentence_id = .data$sentence_id + 1) %>%
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
    dplyr::mutate(doc_id = factor(.data$doc_id, unique(.data$doc_id)))
}