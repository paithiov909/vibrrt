
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vibrrt

<!-- badges: start -->
<!-- badges: end -->

``` r
pkgload::load_all()
#> ℹ Loading vibrrt

audubon::polano[5:8] |>
  tokenize_vec() |>
  prettify(col_select = c("POS1", "POS2")) |>
  dplyr::slice_head(n = 10) |>
  dplyr::glimpse()
#> Rows: 10
#> Columns: 8
#> $ doc_id      <fct> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
#> $ sentence_id <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
#> $ token_id    <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
#> $ word_cost   <int> 3869, 6580, 5608, 3865, -2435, 13661, 8147, 4816, 4391, 83…
#> $ total_cost  <int> 1962, 4173, 10735, 11161, 6535, 18820, 17350, 18240, 20326…
#> $ token       <chr> "その", "ころ", "わたくし", "は", "、", "モリーオ", "市", …
#> $ POS1        <chr> "連体詞", "名詞", "名詞", "助詞", "記号", "名詞", "名詞", …
#> $ POS2        <chr> NA, "非自立", "代名詞", "係助詞", "読点", "固有名詞", "接…
```
