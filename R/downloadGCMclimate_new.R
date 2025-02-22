#' @title downloadGCMClimate_new
#' @description Download GCM climate input used for Lpjml runs
#' @param subtype Switch between different inputs (eg. "ISIMIP3b:IPSL-CM6A-LR:historical:1850-2014:tas")
#' It consists of GCM version, climate model, scenario and variable.
#' @return metadata entry
#' @author  Marcos Alves
#' @examples
#'
#' \dontrun{readSource("GCMClimate_new",  convert="onlycorrect")}

downloadGCMClimate_new <- function(subtype="ISIMIP3b:IPSL-CM6A-LR:ssp126:2015-2100:tas") {

  x           <- toolSplitSubtype(subtype, list(version=NULL, climatemodel=NULL, scenario=NULL, period = NULL, variable=NULL))
  storage     <- "/p/projects/lpjml/input/scenarios"
  path        <- file.path(storage, x$version, gsub("_", "/", x$scenario), x$climatemodel)

  if(!dir.exists(path)) {
    path      <- file.path(storage, x$version, gsub("_", "/", x$scenario), gsub("_","-", x$climatemodel))
  }

  list_files  <- list.files(path)

  if (x$variable == "wet") {x$variable = "pr"} # Wet days are calculated from the precipitation
  file        <- grep(paste0(x$variable,"_"), list_files, value=TRUE)

  file        <- grep(x$period,file, value = TRUE)

  file_path   <- file.path(path, file)

  if (file.exists(file_path)) {
    file.copy(file_path, file)
  } else {
    stop("Data is not available so far!")
  }

  .getMetadata <- function(dataset, version) {
    out <- list(doi = NULL, version = NULL, title = NULL, description = NULL)
    return(out)
  }

  meta <- .getMetadata(x$dataset, x$version)

  # Compose meta data
  return(list(url           = paste0(storage,file_path),
              doi           = NULL,
              title         = x$version,
              author        = NULL,
              version       = x$version,
              release_date  = NULL,
              description   = NULL,
              license       = NULL,
              reference     = NULL)
  )
}
