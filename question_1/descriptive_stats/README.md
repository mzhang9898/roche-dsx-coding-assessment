# descriptiveStats

`descriptiveStats` is an R package that provides six functions for calculating descriptive statistics on numeric vectors. 
It includes input validation, missing-value handling, and support for edge cases.

## Features

The package provides the following functions:

| Function | Description |
|---|---|
| `calc_mean(x)` | Calculates the arithmetic mean |
| `calc_median(x)` | Calculates the median |
| `calc_mode(x)` | Calculates the mode |
| `calc_q1(x)` | Calculates the first quartile |
| `calc_q3(x)` | Calculates the third quartile |
| `calc_iqr(x)` | Calculates the interquartile range |

## Installation

Install and load the package from its local directory:

```r
install.packages("question_1/descriptive_stats")
library(descriptiveStats)
```

## Usage

```r
# Example data
data  <-  c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Use functions
calc_mean(data)  #  3.3 
calc_median(data)  #  4.5 
calc_mode(data)  #  5 
calc_q1(data)  #  2.5 
calc_q3(data)  #  5.5 
calc_iqr(data)  #  3
```

## Edge Case Handling

- **Missing values:** `NA` values are removed before calculations.
- **Empty vectors:** An informative error message is returned.
- **All missing values:** An informative error message is returned.
- **Tied modes:** All values sharing the highest frequency are returned.
- **No mode:** `calc_mode()` returns `numeric(0)`.
- **Invalid inputs:** Include nonnumeric vectors, matrices, arrays, and infinite values (An informative error message is returned).

## Documentation

All six functions are documented using Roxygen2.

To access help for an individual function after installation:

```r
?calc_mean
```

## Testing

Unit tests are implemented using `testthat` package. 

From the package directory, run:

```r
devtools::test()
```
