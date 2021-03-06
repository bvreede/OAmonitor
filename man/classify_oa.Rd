% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/classification.R
\name{classify_oa}
\alias{classify_oa}
\title{Classification of papers}
\usage{
classify_oa(
  df,
  doajdf,
  vsnudf,
  upwdf,
  max_year = "previous",
  custom = F,
  custom_path = "",
  save_results = F
)
}
\arguments{
\item{df}{Source data frame containing doi and issn columns}

\item{doajdf}{Data frame resulting from DOAJ API mining (see `get_doaj()`)}

\item{vsnudf}{VSNU data (see `get_vsnu()`)}

\item{upwdf}{Data frame resulting from unpaywall API mining (see `get_upw()`)}

\item{max_year}{The journal must have been registered in the DOAJ before or during this year}

\item{custom}{Is a custom label applicable?}

\item{custom_path}{Path to the excel file with custom labels}

\item{save_results}{Do you want to save the resulting data frame?}
}
\value{
data frame with Open Access classification (OA_label) and explainer (OA_label_explainer)
}
\description{
Publications are classified based on the information acquired
All publications are classified according to their presence in check lists. In sequence:
1. match the journal ISSN with a list from the Directory of Open Access Journals (DOAJ).
   If the journal matches, the publication is Gold OA
2. match the DOI with a list obtained from VSNU.
   If the journal matches, the publication is Hybrid OA
3. obtain the OA status from Unpaywall.
   If the status is 'gold' or 'hybrid', the publication is Hybrid OA
   If the status is 'green', the publication is Green OA
NB in the classification pipeline these labels will be applied in sequence
Thus, e.g. if ISSN matches DOAJ but Unpaywall says 'green', the label will still be Gold OA.
}
