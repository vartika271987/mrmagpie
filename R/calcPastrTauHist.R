#' @title calcPastrTauHist
#' @description Calculates managed pastures Tau based on FAO yield trends for 1995.
#'
#' @return List of magpie objects with results on country level, weight on country level, unit and description.
#' @author Marcos Alves
#' @examples
#' \dontrun{
#' calcOutput("PastrTauHist")
#' }
#'
calcPastrTauHist <- function() {

  past <- findset("past")
  # Production
  prod <- calcOutput("GrasslandBiomass", aggregate = F)[, past, "pastr"]
  prod <- toolCountryFill(prod, fill = 0)

  # areas
  pastr_weight <- calcOutput("PastureSuit",
    subtype = paste("ISIMIP3b", "MRI-ESM2-0", "1850_2100", sep = ":"), aggregate = F)[, past, 1]
  # regional mapping
  cell2reg <- toolGetMapping("clustermapping.csv", type = "regional")

  # pasture areas
  area <- calcOutput("LUH2v2", landuse_types = "LUH2v2", cellular = F, aggregate = F)[, past, "pastr"]
  area <- toolCountryFill(area, fill = 0)

  # Adding 'otherland' as an extra source of grass biomass comparable to managed pastures in India.
  otherland <- calcOutput("LUH2v2", landuse_types = "LUH2v2", cellular = F, aggregate = F)[, past, c("secdn", "primn")]
  area["IND",,"pastr"] <- area["IND",,"pastr"] + setNames(dimSums(otherland["IND",,], dim = 3), 'pastr')

  # Actual yields
  yact <- prod[, past, ] / area[, past, ]
  yact[is.nan(yact) | is.infinite(yact)] <- 0

  # reference yields
  yref <- calcOutput("GrasslandsYields", lpjml = "lpjml5p2_pasture", climatetype = "MRI-ESM2-0:ssp370", subtype = "/co2/Nreturn0p5/limN" ,
             lsu_levels = c(seq(0, 2.2, 0.2), 2.5), past_mngmt = "me2",
             aggregate = F)[, past, "pastr.rainfed"]

  yref_weights <- calcOutput("LUH2v2", landuse_types = "LUH2v2", cellular = T, aggregate = F)[, past, "pastr"]
  yref <- toolAggregate(yref, rel = cell2reg, from = "cell", to = "country", weight = yref_weights)
  yref <- toolCountryFill(yref, fill = 0)

  # tau calculation
  t <- yact[, past, ] / yref[, past, ]
  t[is.nan(t) | is.infinite(t)] <- 0
  t <- collapseNames(t)

  return(list(
    x = t,
    weight = yref * area, # Xref
    unit = "1",
    description = "Historical trends in managed pastures land use intensity (Tau) based on FAO yield trends"
  ))
}
