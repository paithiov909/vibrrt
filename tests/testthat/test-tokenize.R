### tokenize ----
## TODO: test for user directory
skip_on_cran()
skip_if_offline()

try({
  withr::with_envvar(c(HUGGINGFACE_HUB_CACHE = tempdir()), {
    ipadic <- hfhub::hub_download("ryan-minato/vibrato-models", "ipadic-mecab-2_7_0/system.dic")
    my_tagger <- create_tagger(ipadic)
  })
})

test_that("tokenize for character vector works", {
  df <- tokenize(c(text1 = "\u3053\u3093\u306b\u3061\u306f"), tagger = my_tagger)
  expect_s3_class(df$doc_id, "factor")
  expect_equal(df[[1]][1], factor("text1"))
  expect_equal(df$token[1], "\u3053\u3093\u306b\u3061\u306f")

  lst <- tokenize(c(text1 = "\u3053\u3093\u306b\u3061\u306f"), mode = "wakati", tagger = my_tagger)
  expect_named(lst, "text1")
})

test_that("tokenize for data.frame works", {
  df <- tokenize(
    data.frame(
      doc_id = c(1),
      text = c("\u3053\u3093\u306b\u3061\u306f")
    ),
    tagger = my_tagger
  )
  expect_s3_class(df$doc_id, "factor")
  expect_equal(df[[1]][1], factor("1"))
  expect_equal(df$token[1], "\u3053\u3093\u306b\u3061\u306f")

  lst <- tokenize(
    data.frame(
      doc_id = factor("text1"),
      text = c("\u3053\u3093\u306b\u3061\u306f")
    ),
    split = TRUE,
    mode = "wakati",
    tagger = my_tagger
  )
  expect_named(lst, "text1")
})
