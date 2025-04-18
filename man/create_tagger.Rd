% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenize.R
\name{create_tagger}
\alias{create_tagger}
\title{Create a tagger function}
\usage{
create_tagger(sys_dic, user_dic = "", max_grouping_len = 0L, verbose = FALSE)
}
\arguments{
\item{sys_dic}{Character scalar; path to the system dictionary for 'vibrato'.}

\item{user_dic}{Character scalar; path to the user dictionary for 'vibrato'.}

\item{max_grouping_len}{Integer scalar;
The maximum grouping length for unknown words.
The default value is \code{0L}, indicating the infinity length.}

\item{verbose}{Logical.
If \code{TRUE}, returns additional information for debugging.}
}
\value{
A function inheriting class \code{purrr_function_partial}.
}
\description{
Create a tagger function
}
