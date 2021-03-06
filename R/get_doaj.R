#' @import magrittr
NULL

####################################### API MINING ######################################

#' Get DOAJ data from indicated source
#'
#' This function either kickstarts mining the DOAJ API using the
#' issn columnn in a provided data frame, or loads saved DOAJ data.
#'
#' @param df data frame with an ISSN column
#' @param source either "api" or the path of a saved DOAJ result
#' @param save_results Do you want to save the resulting data frame?
#' @return data frame with DOAJ results
#' @export
get_doaj <- function(df, source="api", save_results=F){
  if(source=="api"){
  df <- df %>%
    api_to_df("doaj") %>%
    process_doaj()
  if(save_results == T){
    save_df(df, "doaj")
    }
  } else if(file.exists(source)){
    #TODO add a check if the dataframe provided matches the saved results
    #TODO rename df, this is confusing
    df <- readr::read_csv(source)
  } else{
    warning("Not sure what DOAJ data to use. Please either use source='api' for use of the DOAJ API,
or provide the path of saved data that was previously mined from the DOAJ API.")
    stop
  }
  return(df)
}


#' Process DOAJ API result
#'
#' Specifically used to process the data frame that results from a doaj mining query.
#' pISSN and eISSN numbers are in separate columns;
#' the dataframe needs to be transformed into long format,
#' with issns in one column and issn types in another column
#'
#' @param df the data frame resulting from a DOAJ API mining
#' @return  cleaned up data frame
process_doaj <- function(df){
  vars = c("bibjson.pissn", "bibjson.eissn")
  df <- df %>%
    # gather issn and issn type information in two columns
    tidyr::pivot_longer(cols = any_of(vars),
                        values_to = "issn",
                        names_to = "issn_type",
                        values_drop_na = F) %>%
    # remove string 'bibjson.' from issn_type
    dplyr::mutate(issn_type = stringr::str_remove(issn_type, "bibjson."))

  return(df)
}


#' Mining the DOAJ API
#'
#' This function uses an issn to mine the
#' DOAJ API (at doaj.org/api/v2/).
#' The entry for this ISSN in the DOAJ is returned.
#'
#' @param issn ISSN for journal that needs to be checked
#' @return list with DOAJ results
#' @export
doaj_api <- function(issn){
  Sys.sleep(0.6) # requests for this api are limited at 2 per second, so the request is slowed down.
  api <- "https://doaj.org/api/v2/search/journals/issn:"
  query <- paste0(api,issn)
  result <- httr::GET(query) %>%
    httr::content(as="text",encoding="UTF-8")
  result_line <- jsonlite::fromJSON(result,flatten=T)$results
  return(result_line)
}
