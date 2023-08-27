
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
install.packages("vibrrt", repos = "https://paithiov909.r-universe.dev")
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
  vibrrt_ipadic = vibrrt::tokenize(
    gibasa::ginga,
    sys_dic = vibrrt::dict_path("ipadic-mecab-2_7_0"),
    mode = "wakati"
  ),
  times = 10L,
  check = "equal"
)
#> Unit: milliseconds
#>           expr      min       lq     mean   median       uq      max neval
#>         gibasa 104.3151 107.1517 113.6609 108.2799 116.5667 151.5655    10
#>  vibrrt_ipadic 400.1805 406.0459 437.5194 423.5166 456.0265 521.1660    10
```

``` r
microbenchmark::microbenchmark(
  gibasa = gibasa::tokenize(
    gibasa::ginga,
    sys_dic = "/usr/local/lib/python3.10/dist-packages/unidic_lite/dicdir",
    mode = "wakati"
  ),
  vibrrt_unidic = vibrrt::tokenize(
    gibasa::ginga,
    sys_dic = vibrrt::dict_path("unidic-mecab-2_1_2"),
    mode = "wakati"
  ),
  times = 5L
)
#> Unit: milliseconds
#>           expr       min       lq     mean   median        uq      max neval
#>         gibasa  386.1541  390.373 1158.620  544.906  630.9402 3840.727     5
#>  vibrrt_unidic 2334.7467 2352.088 2628.865 2404.555 2474.3871 3578.548     5
```
