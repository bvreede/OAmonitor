% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/classification.R
\name{extract_uniques}
\alias{extract_uniques}
\title{Extract unique values without NAs}
\usage{
extract_uniques(column)
}
\arguments{
\item{column}{a vector from which unique values need to be extracted}
}
\value{
a vector of unique values
}
\description{
Uses unique and NA removal to retrieve
a vector of unique entries in a column.
This is useful when mining an API, trying
to minimize the number of calls.
}
