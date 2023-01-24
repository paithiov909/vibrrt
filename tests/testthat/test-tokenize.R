### tokenize ----
test_that("tokenize for character vector works", {
  skip_if_offline()

  tmp <- tempdir()
  ipadic <- dict_path("ipadic-mecab-2_7_0", dict_dir = tmp)
  if (!file.exists(ipadic)) {
    download_dict("ipadic-mecab-2_7_0", dict_dir = tmp)
  }

  df <- tokenize(c(text1 = "\u3053\u3093\u306b\u3061\u306f"), sys_dic = ipadic)
  expect_s3_class(df$doc_id, "factor")
  expect_equal(df[[1]][1], factor("text1"))
  expect_equal(df$token[1], "\u3053\u3093\u306b\u3061\u306f")

  lst <- tokenize(c(text1 = "\u3053\u3093\u306b\u3061\u306f"), sys_dic = ipadic, mode = "wakati")
  expect_named(lst, "text1")
})

test_that("tokenize for data.frame works", {
  skip_if_offline()

  tmp <- tempdir()
  ipadic <- dict_path("ipadic-mecab-2_7_0", dict_dir = tmp)
  if (!file.exists(ipadic)) {
    download_dict("ipadic-mecab-2_7_0", dict_dir = tmp)
  }

  df <- tokenize(
    data.frame(
      doc_id = c(1),
      text = c("\u3053\u3093\u306b\u3061\u306f")
    ),
    sys_dic = ipadic
  )
  expect_s3_class(df$doc_id, "factor")
  expect_equal(df[[1]][1], factor("1"))
  expect_equal(df$token[1], "\u3053\u3093\u306b\u3061\u306f")

  lst <- tokenize(
    data.frame(
      doc_id = factor("text1"),
      text = c("\u3053\u3093\u306b\u3061\u306f")
    ),
    sys_dic = ipadic,
    split = TRUE,
    mode = "wakati"
  )
  expect_named(lst, "text1")
})
