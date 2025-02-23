% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenize.R
\name{tokenize}
\alias{tokenize}
\title{Tokenize sentences using 'vibrato'}
\usage{
tokenize(
  x,
  text_field = "text",
  docid_field = "doc_id",
  sys_dic = "",
  user_dic = "",
  split = FALSE,
  mode = c("parse", "wakati"),
  max_grouping_len = 0L,
  verbose = FALSE
)
}
\arguments{
\item{x}{A data.frame like object or a character vector to be tokenized.}

\item{text_field}{<\code{\link[rlang:args_data_masking]{data-masked}}>
String or symbol; column containing texts to be tokenized.}

\item{docid_field}{<\code{\link[rlang:args_data_masking]{data-masked}}>
String or symbol; column containing document IDs.}

\item{sys_dic}{Character scalar; path to the system dictionary for 'vibrato'.}

\item{user_dic}{Character scalar; path to the user dictionary for 'vibrato'.}

\item{split}{split Logical. When passed as \code{TRUE}, the function
internally splits the sentences into sub-sentences}

\item{mode}{Character scalar to switch output format.}

\item{max_grouping_len}{Integer scalar;
The maximum grouping length for unknown words.
The default value is \code{0L}, indicating the infinity length.}

\item{verbose}{Logical.
If \code{TRUE}, returns additional information for debugging.}
}
\value{
A tibble or a named list of tokens.
}
\description{
Tokenize sentences using 'vibrato'
}
