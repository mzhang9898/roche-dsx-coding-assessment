# Helper Function input_validation unit tests
testthat::test_that("input_validation handles missing values", {
  expect_equal(input_validation(c(1, 2, NA)), c(1, 2))
})

testthat::test_that("input_validation handles empty inputs", {
  expect_error(input_validation(numeric(0)))
  expect_error(input_validation(c(NA)))
})

testthat::test_that("input_validation handles invalid inputs", {
  expect_error(input_validation(c("a", "b")))
  expect_error(input_validation(c(1, Inf)))
  expect_error(input_validation(matrix(1:4, nrow = 1)))
})

# calc_mean unit tests
testthat::test_that("calc_mean calculates the correct mean", {
  expect_equal(calc_mean(c(1, 2, 3)), 2)
  expect_equal(calc_mean(c(1, 2, NA)), 1.5)
  expect_equal(calc_mean(c(1)), 1)
  expect_equal(calc_mean(c(-1, 2)), 0.5)
})

# calc_median unit tests
testthat::test_that("calc_median calculated the correct median", {
  expect_equal(calc_median(c(1, 2, 3)), 2)
  expect_equal(calc_median(c(1, 2, NA)), 1.5)
  expect_equal(calc_median(c(1)), 1)
  expect_equal(calc_median(c(-1, 2)), 0.5)
})

# calc_mode unit tests
testthat::test_that("calc_mode calculated the correct mode", {
  expect_equal(calc_mode(c(1, 2, 2)), 2)
  expect_equal(calc_mode(c(1, 2, 3)), numeric(0))
  expect_equal(calc_mode(c(1, 1, 2, 2)), c(1, 2))
  expect_equal(calc_mode(c(1, 1, 2, NA)), 1)
})

# calc_q1 unit tests
testthat::test_that("calc_q1 calculated the correct 1st quartile", {
  expect_equal(calc_q1(c(1, 2, 3, 4, 5)), 2)
  expect_equal(calc_q1(c(1)), 1)
  expect_equal(calc_q1(c(1, 1)), 1)
  expect_equal(calc_q1(c(1, 2, 3, 4, 5, NA)), 2)
})

# calc_q3 unit tests
testthat::test_that("calc_q3 calculated the correct 1st quartile", {
  expect_equal(calc_q3(c(1, 2, 3, 4, 5)), 4)
  expect_equal(calc_q3(c(1)), 1)
  expect_equal(calc_q3(c(1, 1)), 1)
  expect_equal(calc_q3(c(1, 2, 3, 4, 5, NA)), 4)
  
})

# calc_iqr unit tests
testthat::test_that("calc_iqr calculated the correct 1st quartile", {
  expect_equal(calc_iqr(c(1, 2, 3, 4, 5)), 2)
  expect_equal(calc_iqr(c(1)), 0)
  expect_equal(calc_iqr(c(1, 1)), 0)
  expect_equal(calc_iqr(c(1, 2, 3, 4, 5, NA)), 2)
})

# Quality Standards unit tests
test_that("all functions reject invalid inputs", {
  funcs <- list(
    calc_mean, calc_median, calc_mode, calc_q1, calc_q3, calc_iqr
  )
  
  for (func in funcs) {
    expect_error(func(numeric(0)))
    expect_error(func(c("a", "b")))
    expect_error(func(c(NA, NA)))
    expect_error(func(matrix(1:5, nrow = 1)))
    expect_error(func(c(1, Inf, 3)))
  }
})