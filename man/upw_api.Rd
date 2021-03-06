% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_upw.R
\name{upw_api}
\alias{upw_api}
\title{Mining the Unpaywall API}
\usage{
upw_api(doi, email)
}
\arguments{
\item{doi}{DOI of paper that needs to be checked}

\item{email}{email address of user (required by Unpaywall)}
}
\value{
list with Unpaywall results
}
\description{
Collecting DOI results from Unpaywall using their REST API
(at http://api.unpaywall.org/v2/). The entry for the DOI in the
Unpaywall database is returned.
}
