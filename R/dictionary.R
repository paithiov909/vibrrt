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
                        "unidic-cwj-3_1_1"
                      ),
                      dict_dir = NULL) {
  dict <- rlang::arg_match(dict)
  if (is.null(dict_dir)) {
    dict_dir <- rappdirs::user_cache_dir("vibrrt")
  }
  file.path(dict_dir, dict, "system.dic")
}

#' Download and untar dictionary file
#'
#' @param dict Dictionary name.
#' @param dict_dir Directory where dictionaries are placed.
#' By default, the return value \code{rappdirs::user_cache_dir("vibrrt")} is used.
#' @return The path to the 'system.dic' file is returned invisibly.
#' @seealso \\url{https://github.com/daac-tools/vibrato/releases/tag/v0.3.1}
#' @export
download_dict <- function(dict = c(
                            "ipadic-mecab-2_7_0",
                            "jumandic-mecab-7_0",
                            "naist-jdic-mecab-0_6_3b",
                            "unidic-mecab-2_1_2",
                            "unidic-cwj-3_1_1"
                          ),
                          dict_dir = NULL) {
  dict <- rlang::arg_match(dict)
  url <- switch(dict,
    "ipadic-mecab-2_7_0" = "https://github.com/daac-tools/vibrato/releases/download/v0.3.1/ipadic-mecab-2_7_0.tar.gz",
    "jumandic-mecab-7_0" = "https://github.com/daac-tools/vibrato/releases/download/v0.3.1/jumandic-mecab-7_0.tar.gz",
    "naist-jdic-mecab-0_6_3b" = "https://github.com/daac-tools/vibrato/releases/download/v0.3.1/naist-jdic-mecab-0_6_3b.tar.gz",
    "unidic-mecab-2_1_2" = "https://github.com/daac-tools/vibrato/releases/download/v0.3.1/unidic-mecab-2_1_2.tar.gz",
    "unidic-cwj-3_1_1" = "https://github.com/daac-tools/vibrato/releases/download/v0.3.1/unidic-cwj-3_1_1.tar.gz"
  )
  if (is.null(dict_dir)) {
    dict_dir <- rappdirs::user_cache_dir("vibrrt")
  }

  if (!dir.exists(file.path(dict_dir, dict))) {
    dir.create(file.path(dict_dir, dict), recursive = TRUE)
  }

  if (!file.exists(file.path(tempdir(), paste0(dict, ".tar.gz")))) {
    download.file(
      url,
      destfile = file.path(tempdir(), paste0(dict, ".tar.gz"))
    )
  }

  gz <- gzfile(
    file.path(tempdir(), paste0(dict, ".tar.gz")),
    open = "r+b"
  )
  on.exit(close(gz))
  untar(gz, exdir = file.path(dict_dir))

  return(invisible(dict_path(dict)))
}
