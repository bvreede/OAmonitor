% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_data.R
\name{open_everything}
\alias{open_everything}
\title{Open all files and return a dataframe}
\usage{
open_everything(file, dir = "")
}
\arguments{
\item{file}{The (entire!) path to the (filled out) excel template file.}

\item{dir}{The path to the folder in which all data content files are located.}
}
\value{
a data frame combining all file content
}
\description{
This function can be used in the package OAmonitor to
open all files on which information is filled out in an
excel template.
The files will have to be stored in the data folder
and formatted either as tsv, csv, xls, or xlsx.
}
