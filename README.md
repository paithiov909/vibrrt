
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vibrrt

<!-- badges: start -->

[![vibrrt status
badge](https://paithiov909.r-universe.dev/badges/vibrrt)](https://paithiov909.r-universe.dev)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/paithiov909/vibrrt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

An R wrapper for ‘[vibrato](https://github.com/daac-tools/vibrato)’:
Viterbi-based accelerated tokenizer.

## Installation

To install from source package, the Rust toolchain is required.

``` r
install.packages("vibrrt", repos = c("https://paithiov909.r-universe.dev", "https://cloud.r-project.org"))
```

## Usage

You can download the model files from
[ryan-minato/vibrato-models](https://huggingface.co/ryan-minato/vibrato-models)
using [hfhub](https://github.com/mlverse/hfhub) package.

``` r
sample_text <- jsonlite::read_json(
  "https://paithiov909.r-universe.dev/gibasa/data/ginga/json",
  simplifyVector = TRUE
)

# withr::with_envvar(c(HUGGINGFACE_HUB_CACHE = tempdir()), {
ipadic <- hfhub::hub_download("ryan-minato/vibrato-models", "ipadic-mecab-2_7_0/system.dic")
# })

vibrrt::tokenize(
  sample_text[5:8],
  tagger = vibrrt::create_tagger(ipadic)
)
#> # A tibble: 187 × 5
#>    doc_id sentence_id token_id token        feature                             
#>    <fct>        <int>    <int> <chr>        <chr>                               
#>  1 1                1        1 　           記号,空白,*,*,*,*,　,　,　          
#>  2 1                1        2 カムパネルラ 名詞,一般,*,*,*,*,*                 
#>  3 1                1        3 が           助詞,格助詞,一般,*,*,*,が,ガ,ガ     
#>  4 1                1        4 手           名詞,一般,*,*,*,*,手,テ,テ          
#>  5 1                1        5 を           助詞,格助詞,一般,*,*,*,を,ヲ,ヲ     
#>  6 1                1        6 あげ         動詞,自立,*,*,一段,連用形,あげる,アゲ,アゲ……
#>  7 1                1        7 まし         助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ……
#>  8 1                1        8 た           助動詞,*,*,*,特殊・タ,基本形,た,タ,タ……
#>  9 1                1        9 。           記号,句点,*,*,*,*,。,。,。          
#> 10 1                1       10 それ         名詞,代名詞,一般,*,*,*,それ,ソレ,ソレ……
#> # ℹ 177 more rows
```

## Versioning

This package is versioned by copying the version number of
[vibrato](https://github.com/daac-tools/vibrato), where the first three
digits represent that version number and the fourth digit (if any)
represents the patch release for this package.
