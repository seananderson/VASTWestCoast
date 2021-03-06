devtools::install_github("James-Thorson/FishStatsUtils")
devtools::install_github("nwfsc-assess/VASTWestCoast")
library(VASTWestCoast)
library(TMB)
Sim_Settings <- list(
  "Species" = "WCGBTS_Anoplopoma_fimbria",
  "ObsModelcondition" = c(2, 1),
  "nknots" = 250,
  "strata" = data.frame("STRATA" = "All_areas"),
  "depth" = c("no", "linear", "squared")[1],
  "version" = "VAST_v5_2_0",
  "Passcondition" = FALSE)

downloaddir <- getwd()

test <- VAST_condition(
  conditiondir = downloaddir,
  settings = Sim_Settings, spp = Sim_Settings$Species,
  datadir = downloaddir,
  overdisperion = NULL)
VAST_diagnostics(downloaddir)
