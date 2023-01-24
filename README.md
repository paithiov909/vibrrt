
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vibrrt

<!-- badges: start -->

[![vibrrt status
badge](https://paithiov909.r-universe.dev/badges/vibrrt)](https://paithiov909.r-universe.dev)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
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

audubon::polano[5:8] |>
  vibrrt::tokenize(sys_dic = ipadic) |>
  vibrrt::prettify(col_select = c("POS1", "POS2")) |>
  dplyr::glimpse()
#> Rows: 385
#> Columns: 8
#> $ doc_id      <fct> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2…
#> $ sentence_id <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2…
#> $ token_id    <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,…
#> $ word_cost   <int> 3869, 6580, 5608, 3865, -2435, 13661, 8147, 4816, 4391, 83…
#> $ total_cost  <int> 1962, 4173, 10735, 11161, 6535, 18820, 17350, 18240, 20326…
#> $ token       <chr> "その", "ころ", "わたくし", "は", "、", "モリーオ", "市", …
#> $ POS1        <chr> "連体詞", "名詞", "名詞", "助詞", "記号", "名詞", "名詞", …
#> $ POS2        <chr> NA, "非自立", "代名詞", "係助詞", "読点", "固有名詞", "接…
```
