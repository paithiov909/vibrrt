### as_tokens ----
test_that("as_tokens works", {
  skip_if_offline()

  tmp <- tempdir()
  ipadic <- dict_path("ipadic-mecab-2_7_0", dict_dir = tmp)
  if (!file.exists(ipadic)) {
    download_dict("ipadic-mecab-2_7_0", dict_dir = tmp)
  }

  lst <-
    tokenize(
      data.frame(
        doc_id = factor("text1"),
        text = c("\u3053\u3093\u306b\u3061\u306f")
      ),
      sys_dic = ipadic
    ) |>
    prettify(col_select = 1) |>
    as_tokens()
  expect_named(lst, "text1")
})

### is_blank ----
test_that("is_blank works", {
  expect_true(is_blank(NaN))
  expect_true(is_blank(NA_character_))
  expect_true(is_blank(NULL))
  expect_true(is_blank(list()))
  expect_true(is_blank(c()))
  expect_true(is_blank(data.frame()))
  expect_equal(
    c(TRUE, TRUE, TRUE, FALSE),
    is_blank(list(NA_character_, NA_integer_, NULL, "test"))
  )
})

### prettify ----
test_that("prettify works", {
  skip_if_offline()

  tmp <- tempdir()
  ipadic <- dict_path("ipadic-mecab-2_7_0", dict_dir = tmp)
  if (!file.exists(ipadic)) {
    download_dict("ipadic-mecab-2_7_0", dict_dir = tmp)
  }

  df <- tokenize(c(text1 = "\u3053\u3093\u306b\u3061\u306f"), sys_dic = ipadic)
  expect_error(prettify(df, col_select = c(1, 10)))
  expect_equal(ncol(prettify(df)), 15L)
  expect_equal(ncol(prettify(df, col_select = c(1, 2, 3))), 9L)
  expect_equal(ncol(prettify(df, col_select = 1:3)), 9L)
  expect_equal(ncol(prettify(df, col_select = c("POS1", "POS2", "POS3"))), 9L)
})
