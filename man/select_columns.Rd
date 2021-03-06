% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_data.R
\name{select_columns}
\alias{select_columns}
\title{Keep only specific columns in a data frame}
\usage{
select_columns(data, col_keep)
}
\arguments{
\item{data}{data frame}

\item{col_keep}{vector with column names that should be kept}
}
\value{
a data frame with reduced number of columns
}
\description{
This function can be used when, apart from the standardized columns,
there is a selection of columns in the data frame that should be kept around.
The function was written because columns can create conflicts when multiple
data frames are joined that carry columns with the same name but different
data types. Removing excess columns prevents this.
}
