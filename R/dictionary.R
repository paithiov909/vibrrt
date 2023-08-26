#' Get the path to a dictionary file
#'
#' @param dict Dictionary name.
#' @param dict_dir Directory where dictionaries are placed.
#' By default, the return value \code{rappdirs::user_cache_dir("vibrrt")} is used.
#' @export
dict_path <- function(dict = c(
                        "ipadic-mecab-2_7_0",
                        "jumandic-mecab-7_0",
                        "naist-jdic-mecab-0_6_3b",
                        "unidic-mecab-2_1_2",
                        "unidic-cwj-3_1_1+compact-dual"
                      ),
                      dict_dir = NULL) {
  dict <- rlang::arg_match(dict)
  if (is.null(dict_dir)) {
    dict_dir <- rappdirs::user_cache_dir("vibrrt")
  }
  file.path(dict_dir, dict, "system.dic.zst")
}

#' Download dictionary file
#'
#' @param dict Dictionary name.
#' @param dict_dir Directory where dictionaries are placed.
#' By default, the return value \code{rappdirs::user_cache_dir("vibrrt")} is used.
#' @return The path to the 'system.dic' file is returned invisibly.
#' @seealso \url{https://github.com/daac-tools/vibrato/releases/tag/v0.5.0}
#' @export
download_dict <- function(dict = c(
                            "ipadic-mecab-2_7_0",
                            "jumandic-mecab-7_0",
                            "naist-jdic-mecab-0_6_3b",
                            "unidic-mecab-2_1_2",
                            "unidic-cwj-3_1_1+compact-dual"
                          ),
                          dict_dir = NULL) {
  dict_prefix <- "https://github.com/daac-tools/vibrato/releases/download"
  dict_version <- "v0.5.0"
  dict <- rlang::arg_match(dict)

  url <- switch(dict,
    "ipadic-mecab-2_7_0" = paste(dict_prefix, dict_version, "ipadic-mecab-2_7_0.tar.xz", sep = "/"),
    "jumandic-mecab-7_0" = paste(dict_prefix, dict_version, "jumandic-mecab-7_0.tar.xz", sep = "/"),
    "naist-jdic-mecab-0_6_3b" = paste(dict_prefix, dict_version, "naist-jdic-mecab-0_6_3b.tar.xz", sep = "/"),
    "unidic-mecab-2_1_2" = paste(dict_prefix, dict_version, "unidic-mecab-2_1_2.tar.xz", sep = "/"),
    "unidic-cwj-3_1_1+compact-dual" = paste(dict_prefix, dict_version, "unidic-cwj-3_1_1+compact-dual.tar.xz", sep = "/")
  )
  if (is.null(dict_dir)) {
    dict_dir <- rappdirs::user_cache_dir("vibrrt")
  }

  if (!dir.exists(file.path(dict_dir))) {
    dir.create(file.path(dict_dir), recursive = TRUE)
  }

  temp <- file.path(tempdir(), paste0(dict, ".tar.xz"))
  if (!file.exists(temp)) {
    utils::download.file(
      url,
      destfile = temp
    )
  }
  utils::untar(temp, exdir = path.expand(dict_dir))

  return(invisible(dict_path(dict)))
}
