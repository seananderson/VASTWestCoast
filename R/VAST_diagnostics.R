###############################################################################
###############################################################################
#### First attempt at some diagnostic plots
#### Author: Kelli Faye Johnson
#### Date: 2018-08-16
###############################################################################
###############################################################################

VAST_diagnostics <- function(dir = getwd()) {
  # Load the saved file
  e1 <- new.env()
  savedfile <- dir(dir, pattern = "^Save.RData", full.names = TRUE)
  datafile <- dir(dir, pattern = "DatabaseSave.RData", full.names = TRUE)
  setupfile <- dir(dir, pattern = "setup.RData", full.names = TRUE)
  base::load(savedfile, envir = e1)
  base::load(datafile, envir = e1)
  base::load(setupfile, envir = e1)

  if(is.null(get("info", envir = e1)$region)) {
    region <- switch(
      strsplit(get("settings", envir = e1)$Species, "_")[[1]][1],
      EBSBTS = "eastern_bering_sea",
      WCGBTS = "California_current",
      NULL)
  }

  # Check convergence
  sink(file.path(dir, "convergence_gradient.txt"))
  pander::pandoc.table(
    get("Opt", envir = e1)$diagnostics[,
      c("Param","Lower","MLE","Upper","final_gradient")])
  sink()
  # Check encounter probability
  encprob <- FishStatsUtils::plot_encounter_diagnostic(
    Report = get("Report", envir = e1),
    Data_Geostat = get("Database", envir = e1),
    DirName = dir)

  # Check positive catch rates
  # Won't work for Poisson-link
  Q <- FishStatsUtils::plot_quantile_diagnostic(
    TmbData = get("TmbData", envir = e1),
    Report = get("Report", envir = e1),
    FileName_PP = "Posterior_Predictive",
    FileName_Phist = "Posterior_Predictive-Histogram",
    FileName_QQ = "Q-Q_plot",
    FileName_Qhist = "Q-Q_hist",
    DateFile = dir)
  MapDetails_List <- FishStatsUtils::make_map_info(
    "Region" = region,
    "NN_Extrap" = get("info", e1)$Spatial_List$NN_Extrap,
    "Extrapolation_List" = get("info", envir = e1)$Extrapolation_List)
  years <- get("Database", envir = e1)$Year
  Year_Set <- seq(min(years), max(years))
  Years2Include <- which(Year_Set %in% sort(unique(years)))
  FishStatsUtils::plot_residuals(
    Lat_i = get("Database", envir = e1)$Lat,
    Lon_i = get("Database", envir = e1)$Lon,
    TmbData = get("TmbData", envir = e1),
    Report = get("Report", envir = e1),
    Q = Q, savedir = dir, FileName = paste0(dir, .Platform$path.sep),
    MappingDetails = MapDetails_List[["MappingDetails"]],
    PlotDF = MapDetails_List[["PlotDF"]],
    MapSizeRatio = MapDetails_List[["MapSizeRatio"]],
    Xlim = MapDetails_List[["Xlim"]],
    Ylim = MapDetails_List[["Ylim"]],
    Year_Set = Year_Set, Years2Include = Years2Include,
    Rotate = MapDetails_List[["Rotate"]],
    Cex = MapDetails_List[["Cex"]], Legend = MapDetails_List[["Legend"]],
    zone = MapDetails_List[["Zone"]],
    mar = c(0, 0, 2, 0), oma = c(3.5, 3.5 ,0, 0), cex = 1.8)

  # Plot anisotropy
  FishStatsUtils::plot_anisotropy(
    FileName = file.path(dir, "Aniso.png"),
    TmbData = get("TmbData", envir = e1),
    Report = get("Report", envir = e1))

  # Spatial and spatiotemporal covariance
  data <- get("Database", envir = e1)
  ncats <- length(unique(data[, grep("Sci", colnames(data))[1]]))
  if (ncats > 1){
    Cov_List <- VAST::Summarize_Covariance(
      Report = get("Report", envir = e1),
      ParHat = get("ParHat", envir = e1),
      Data = get("TmbData", envir = e1),
      SD = get("Opt", envir = e1)$SD,
      plot_cor = FALSE,
      category_names = levels(get("Database", envir = e1)$Sci),
      plotdir = dir, plotTF = get("TmbData", envir = e1)$FieldConfig,
      mgp = c(2, 0.5, 0), tck = -0.02, oma = c(0, 5, 2, 2))
  }

  # Density surface
  Dens_xt <- FishStatsUtils::plot_maps(
    plot_set = c(3),
    MappingDetails = MapDetails_List[["MappingDetails"]],
    PlotDF = MapDetails_List[["PlotDF"]],
    MapSizeRatio = MapDetails_List[["MapSizeRatio"]],
    Xlim = MapDetails_List[["Xlim"]], Ylim = MapDetails_List[["Ylim"]],
    Rotate = MapDetails_List[["Rotate"]],
    Cex = MapDetails_List[["Cex"]],
    Legend = MapDetails_List[["Legend"]],
    zone = MapDetails_List[["Zone"]],
    Report = get("Report", envir = e1),
    Sdreport = get("Opt", envir = e1)$SD,
    FileName = paste0(dir, .Platform$path.sep),
    Year_Set = Year_Set, Years2Include = Years2Include,
    mar = c(0, 0, 2, 0), oma = c(3.5, 3.5, 0, 0),
    cex = 1.8, plot_legend_fig = FALSE)
  Dens_DF <- cbind(
    "Density" = as.vector(Dens_xt),
    "Year" = Year_Set[col(Dens_xt)],
    "E_km" = get("info", e1)$Spatial_List$MeshList$loc_x[row(Dens_xt), "E_km"],
    "N_km" = get("info", e1)$Spatial_List$MeshList$loc_x[row(Dens_xt), "N_km"])
  sink(file = file.path(dir, "densityperknot.txt"))
    pander::pandoc.table(Dens_DF, digits = 3)
  sink()

  # Range shifts
  if (get("TmbData", envir = e1)$Options["Calculate_effective_area"] == 1) {
    FishStatsUtils::plot_range_index(
      Report = get("Report", envir = e1),
      TmbData = get("TmbData", envir = e1),
      Sdreport = get("Opt", envir = e1)[["SD"]],
      Znames = colnames(get("Report", envir = e1)$Z_xm),
      PlotDir = paste0(dir, .Platform$path.sep),
      Year_Set = Year_Set)
  }
  invisible()
}





