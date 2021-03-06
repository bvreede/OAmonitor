% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_data.R
\name{column_rename}
\alias{column_rename}
\title{Renaming columns to standard names}
\usage{
column_rename(data, col_config, template)
}
\arguments{
\item{data}{dataframe with original column names}

\item{col_config}{vector with the original column names, sorted by a standard}

\item{template}{vector with the description of standard columns (this must be the File_info column in the excel template)}
}
\value{
dataframe with renamed columns
}
\description{
Using a filled out template, this function renames columns with certain content
(as indicated in the template) to standard names, so different data frames
can easily be joined together.
}
