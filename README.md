
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vibrrt

> An R wrapper for ‘[Vibrato](https://github.com/daac-tools/vibrato)’:
> Viterbi-based accelerated tokenizer

<!-- badges: start -->

[![vibrrt status
badge](https://paithiov909.r-universe.dev/badges/vibrrt)](https://paithiov909.r-universe.dev)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

To install from source package, the Rust toolchain is required.

``` r
install.packages("vibrrt", repos = c("https://paithiov909.r-universe.dev", "https://cloud.r-project.org"))
```

## Usage

You can download the model files from
[ryan-minato/vibrato-models](https://huggingface.co/ryan-minato/vibrato-models)
using [hfhub](https://github.com/mlverse/hfhub) package.

Functions are designed in the same fashion as in the
[gibasa](https://github.com/paithiov909/gibasa) package. Check the
README of the gibasa package for more detailed usage.

``` r
sample_text <- jsonlite::read_json(
  "https://paithiov909.r-universe.dev/gibasa/data/ginga/json",
  simplifyVector = TRUE
)

withr::with_envvar(c(HUGGINGFACE_HUB_CACHE = tempdir()), {
  ipadic <- hfhub::hub_download("ryan-minato/vibrato-models", "ipadic-mecab-2_7_0/system.dic")
})
#> ipadic-mecab-2_7_0/system.dic ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ |  48 MB/ 48 MB E…

vibrrt::tokenize(sample_text[5:8], sys_dic = ipadic)
#> # A tibble: 187 × 7
#>    doc_id sentence_id token_id token        feature         word_cost total_cost
#>    <fct>        <dbl>    <dbl> <chr>        <chr>               <int>      <int>
#>  1 1                1        1 　           記号,空白,*,*,*,*,…      1287        993
#>  2 1                1        2 カムパネルラ 名詞,一般,*,*,*,*,…      9461      10379
#>  3 1                1        3 が           助詞,格助詞,一般,*,*,…      3866       9524
#>  4 1                1        4 手           名詞,一般,*,*,*,*,…      5631      14331
#>  5 1                1        5 を           助詞,格助詞,一般,*,*,…      4183      13521
#>  6 1                1        6 あげ         動詞,自立,*,*,一段,連…      9908      20097
#>  7 1                1        7 まし         助動詞,*,*,*,特殊・マ…      6320      17966
#>  8 1                1        8 た           助動詞,*,*,*,特殊・タ…      5500      17369
#>  9 1                1        9 。           記号,句点,*,*,*,*,…       215      13935
#> 10 1                1       10 それ         名詞,代名詞,一般,*,*,…      4818      18710
#> # ℹ 177 more rows
```
