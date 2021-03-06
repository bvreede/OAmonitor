#' @import magrittr
NULL

#' Open all files and return a dataframe
#'
#' This function can be used in the package OAmonitor to
#' open all files on which information is filled out in an
#' excel template.
#' The files will have to be stored in the data folder
#' and formatted either as tsv, csv, xls, or xlsx.
#' @param file The (entire!) path to the (filled out) excel template file.
#' @param dir The path to the folder in which all data content files are located.
#' @return a data frame combining all file content
#' @export
open_everything <- function(file, dir=""){
  allfiles <- readxl::read_excel(file)

  alldata <- list()
  template = allfiles$File_info

  for(col in allfiles[2:length(allfiles)]){
    # extract file name and extension
    fn <- col[template=="Filename"]
    fn_ext <- col[template=="Format (tsv, csv, xls, or xlsx)"]
    fn_ext <- stringr::str_replace(fn_ext,'[:punct:]','')

    # test if the column contains NAs; in this case the file will not be read
    if(sum(is.na(col))>1){
      warning("The information for file ", fn, " is not filled out. This file cannot be processed.\n")
      next
    }
    # skip filenames without valid extensions
    if(!fn_ext %in% c("xlsx","xls","csv","tsv")){
      warning("The filename ", fn, " does not have a valid extension provided. This file cannot be processed.\n")
      next
    }

    # open the file, clean columns, and save to the alldata list
    alldata[[fn]] <- open_clean(col,template,dir)
  }

  # remove excess variables, bind to dataframe
  df <- dplyr::bind_rows(alldata)

  # check the system IDs for duplicates
  system_id_check(df)

  return(df)
}

#' Determines format and reads in tabular data
#'
#' Using the filename, this function uses tidyverse read
#' functions to open a data file.
#' @param fn the filename
#' @param ext the file extension (may also be provided by filename). Can be "csv", "tsv", "xls", or "xlsx".
#' @param dir folder location (path) of the file
#' @return a data frame
#' @export
read_ext <- function(fn, ext="", dir=""){
  # opening a file, with method depending on the extension
  # extract extension and put together filename
  if(ext == ""){
  fn_ext <- stringr::str_split(fn,"\\.")[[1]]
  ext <- fn_ext[-1]
  }

  # construct file path
  if(dir != "" & stringr::str_sub(dir,-1L)!= "/"){
      dir = paste0(dir,"/")
    }
  fn_path <- paste0(dir,fn)

  if(ext == "csv"){
    # multiple methods are possible, check which one yields the largest no. of columns
    # this is quite hacky, and generates unnecessary warnings. It does work though...
    df1 <- suppressWarnings(readr::read_delim(fn_path, delim=";"))
    df2 <- suppressWarnings(readr::read_delim(fn_path, delim=","))
    if(ncol(df1)>ncol(df2)){
      df <- df1
    } else{
      df <- df2
    }
    rm(df1,df2)
  } else if(ext=="tsv"){
    df <- readr::read_delim(fn_path,delim="\t", escape_double = FALSE, trim_ws = TRUE)
  } else if(ext=="xls"|ext=="xlsx"){
    df <- readxl::read_excel(fn_path)
  }
  return(df)
}

#' Renaming columns to standard names
#'
#' Using a filled out template, this function renames columns with certain content
#' (as indicated in the template) to standard names, so different data frames
#' can easily be joined together.
#'
#' @param data dataframe with original column names
#' @param col_config vector with the original column names, sorted by a standard
#' @param template vector with the description of standard columns (this must be the File_info column in the excel template)
#' @return dataframe with renamed columns
column_rename <- function(data,col_config,template){
  # rename column names
  id_column <- col_config[template=="Internal unique identifier"]
  issn_column <- col_config[template=="ISSN"]
  eissn_column <- col_config[template=="EISSN (electronic ISSN)"]
  doi_column <- col_config[template=="DOI"]
  org_column <- col_config[template=="Departments and/or faculties"]
  colnames(data)[colnames(data) == id_column] <- "system_id"
  colnames(data)[colnames(data) == issn_column] <- "issn"
  # if there is no EISSN, generate a column
  if(eissn_column %in% colnames(data)){
    colnames(data)[colnames(data) == eissn_column] <- "eissn"
  } else{
      data <- dplyr::mutate(data, eissn = NA)
    }
  colnames(data)[colnames(data) == doi_column] <- "doi"
  colnames(data)[colnames(data) == org_column] <- "org_unit"

  # turn system ID column into character
  data <- data %>% dplyr::mutate(system_id = as.character(system_id))

  # return renamed data
  return(data)
}

#' Keep only specific columns in a data frame
#'
#' This function can be used when, apart from the standardized columns,
#' there is a selection of columns in the data frame that should be kept around.
#' The function was written because columns can create conflicts when multiple
#' data frames are joined that carry columns with the same name but different
#' data types. Removing excess columns prevents this.
#'
#' @param data data frame
#' @param col_keep vector with column names that should be kept
#' @return a data frame with reduced number of columns
select_columns <- function(data,col_keep){
  data <- data %>%
    dplyr::select(system_id,
           issn,
           eissn,
           doi,
           org_unit,
           tidyselect::all_of(col_keep))
  return(data)
}

#' Turn string (length 8) into ISSN
#'
#' An ISSN is formatted as NNNN-NNNX, where N is a number, and X can be any number or character.
#' If ISSNs are formatted differently, this can give errors when using a public API, so they can be
#' reformatted with this function.
#' A string with a different length will return NA.
#'
#' @param number string of length 8 (often a number)
#' @return ISSN-formatted string.
number_to_issn <- function(number){
  # ensure ISSN has two elements, with a hyphen in between
  if(is.na(number)){
    return(NA)
  }
  if(stringr::str_length(number)!=8){
    return(NA)
  }
  part1 <- stringr::str_sub(number, start = 1L, end = 4L)
  part2 <- stringr::str_sub(number, start = 5L, end = 8L)
  return(paste0(part1,"-",part2))
}

#' Clean ISSNs
#'
#' This function removes whitespace and punctuation from ISSNs
#' and returns them in correct ISSN format.
#' An ISSN is formatted as NNNN-NNNX, where N is a number, and X can be any number or character.
#' If ISSNs are formatted differently, this can give errors when using a public API, so they can be
#' reformatted with this function.
#' A string with a different length will return NA.
#'
#' @param column ISSN(s)
#' @return cleaned ISSN(s), vectorized
#' @export
clean_issn <- function(column){
  column <- stringr::str_replace(column,'\\s+','') #remove spaces from ISSN
  column <- stringr::str_replace_all(column,'[:punct:]','') #remove all punctuation
  column <- stringr::str_sub(column, 1,8) # only take the first 8 elements so that duplicate ISSNs are removed
  # ensure ISSN has two elements, with a hyphen in between
  column <- mapply(number_to_issn,column)
  return(column)
}

#' Clean DOIs
#'
#' This function removes url information, whitespace, and punctuation from DOIs
#' and returns them in correct format, all characters converted to lowercase. Any
#' additional DOIs separated by commas will also be removed so each field will contain
#' only a single DOI.
#'
#' @param column DOI(s)
#' @return cleaned DOI(s), vectorized
#' @export
clean_doi <- function(column){
  column <- stringr::str_extract(column,"10\\..+") #ensure only dois are kept, without url information
  column <- stringr::str_replace_all(column,'\\s+','') #remove spaces from DOI
  column <- tolower(column) #Change DOI to lowercase only
  column <- stringr::str_replace(column,",.+","") #remove duplicate DOIs separated with a comma
  return(column)
}

#' Open and clean up source data
#'
#' This function opens a source file, then changes column headers to a standard format,
#' removes any superfluous columns (if indicated in the excel template), and cleans DOI
#' and ISSN columns using `clean_doi` and `clean_issn` functions.
#'
#' @param col_config vector with the original column names, sorted by a standard
#' @param template vector with the description of standard columns (this must be the File_info column in the excel template)
#' @param dir folder location (path) of the described file
#' @return cleaned data frame
open_clean <- function(col_config, template, dir){
  # extract file name
  fn <- col_config[template=="Filename"]
  fn_ext <- col_config[template=="Format (tsv, csv, xls, or xlsx)"]
  fn_ext <- stringr::str_replace(fn_ext,'[:punct:]','')

  # what columns to keep?
  col_keep <- col_config[template=="Other columns to include"]
  col_keep <- stringr::str_split(col_keep,", ") %>% unlist()

  # open the file and adjust the column names to the config input
  df <- read_ext(fn,ext=fn_ext, dir = dir) %>%
    column_rename(col_config,template)

  # reduce number of columns, except when the user wants to keep all
  if(!"all" %in% col_keep){
    df <- select_columns(df, col_keep)
  }

  # clean DOI and ISSN, remove spaces and hyperlinks, change uppercase to lowercase etc.
  # also add source file column
  df <- df %>% dplyr::mutate(issn = clean_issn(issn),
                      eissn = clean_issn(eissn),
                      doi = clean_doi(doi),
                      source = fn)

  return(df)
}

#' Checking system ID columns for duplicate
#'
#' Checks that there are no duplicate system IDs between
#' multiple source files, as this may be accidental and cause problems
#' with deduplication and other assignments later on.
#' If this function finds duplicates, these duplicates are stored in the
#'
#' @param df data frame with `system_id` and `source` column.
system_id_check <- function(df){
  sources <- df$source %>%
    as.factor() %>%
    levels()
  all_ids <- c()
  duplicates <- c()
  for(s in sources){
    ids <- df %>%
      dplyr::filter(source == s) %>%
      dplyr::pull(system_id)
    duplicates <- c(duplicates,ids[ids%in%all_ids])
    all_ids <- c(all_ids,ids)
  }
  if(length(duplicates) > 0){
    if (!file.exists(here::here("output"))){
      dir.create(here::here("output"))
    }
    df %>% dplyr::filter(system_id%in%duplicates) %>%
      readr::write_csv("output/confirm_duplicate_IDs.csv")
    warning("
  Duplicate IDs exist between different imported datasets.
  Please ensure that these refer to the same files.
  For your convenience, all lines corresponding to duplicate IDs are saved in output/confirm_duplicate_IDs.csv")
  }
}
