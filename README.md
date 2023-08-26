
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vibrrt

> An R wrapper of ‘[Vibrato](https://github.com/daac-tools/vibrato)’:
> Viterbi-based accelerated tokenizer

<!-- badges: start -->

[![vibrrt status
badge](https://paithiov909.r-universe.dev/badges/vibrrt)](https://paithiov909.r-universe.dev)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Installation

``` r
# install.packages("vibrrt", repos = "https://paithiov909.r-universe.dev")
```

## Usage

``` r
ipadic <- vibrrt::dict_path("ipadic-mecab-2_7_0")
if (!file.exists(ipadic)) {
  vibrrt::download_dict("ipadic-mecab-2_7_0")
}

gibasa::ginga[5:10] |>
  vibrrt::tokenize(sys_dic = ipadic) |>
  vibrrt::prettify(col_select = c("POS1", "POS2"))
```

## Benchmark

``` r
microbenchmark::microbenchmark(
  gibasa = gibasa::tokenize(gibasa::ginga, mode = "wakati"),
  vibrrt = vibrrt::tokenize(
    gibasa::ginga,
    sys_dic = vibrrt::dict_path("ipadic-mecab-2_7_0"),
    mode = "wakati"
  ),
  times = 10L,
  check = "equal"
)
#> Unit: milliseconds
#>    expr      min       lq     mean   median       uq      max neval
#>  gibasa 102.5175 109.0075 121.7043 112.4550 118.7941 176.7678    10
#>  vibrrt 392.7126 402.6038 433.9819 424.9284 464.0350 491.4648    10
```
