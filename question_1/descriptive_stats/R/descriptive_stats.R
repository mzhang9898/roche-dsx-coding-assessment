#' Quality Standards
#' @param x Numeric vector.
#' @return Numeric Vector without missing values.
input_validation <- function(x) {
  if (!is.numeric(x) || !is.null(dim(x))) {
    stop("Input must be a numeric vector.", call. = FALSE)
  }
  
  if (any(is.infinite(x))) {
    stop("Input cannot contain infinite values.", call. = FALSE)
  }
  
  non_na <- x[!is.na(x)]
  
  if (length(non_na) == 0) {
    stop("Input must contain at least one non-null value.", call. = FALSE)
  }
  
  return(non_na)
}

#' Calculate arithmetic mean
#' @param x Numeric vector.
#' @return Arithmetic mean.
#' @examples
#' # calc_mean(c(1, 2, 3, 4))
#' @export
calc_mean <- function(x) {
  return(mean(input_validation(x)))
}

#' Calculate median
#' @param x Numeric vector.
#' @return Median.
#' @examples
#' # calc_median(c(1, 2, 3, 4))
#' @export
calc_median <- function(x) {
  return(median(input_validation(x)))
}

#' Calculate mode
#' @param x Numeric vector.
#' @return Numeric vector with mode(s).
#' @examples
#' # calc_mode(c(1, 2, 3, 4))
#' # calc_mode(c(1, 1, 2, 2))
#' @export
calc_mode <- function(x) {
  freq <- table(input_validation(x))
  
  # No mode case
  if (all(freq == 1)) {
    return(numeric(0))
  }
  
  return(as.numeric(names(freq)[freq == max(freq)]))
}

#' Calculate 1st quartile
#' @param x Numeric vector.
#' @return 1st quartile.
#' @examples
#' # calc_q1(c(1, 2, 3, 4))
#' @export
calc_q1 <- function(x) {
  return(quantile(input_validation(x), 0.25, names = FALSE))
}

#' Calculate 3rd quartile
#' @param x Numeric vector.
#' @return 3rd quartile.
#' @examples
#' # calc_q3(c(1, 2, 3, 4))
#' @export
calc_q3 <- function(x) {
  return(quantile(input_validation(x), 0.75, names = FALSE))
}

#' Calculate interquartile range
#' @param x Numeric vector.
#' @return interquartile range.
#' @examples
#' # calc_iqr(c(1, 2, 3, 4))
#' @export
calc_iqr <- function(x) {
  return(calc_q3(x) - calc_q1(x))
}