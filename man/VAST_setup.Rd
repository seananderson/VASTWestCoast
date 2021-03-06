% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VAST_setup.R
\name{VAST_setup}
\alias{VAST_setup}
\title{Set up the spatial information for a \link{[VAST]} run.}
\usage{
VAST_setup(data, dir, regionacronym, strata = NULL, nknots)
}
\arguments{
\item{data}{A data frame with columns for Latitude and Longitude labeled using
abbreviations "Lat" and "Lon" and column labeled "Year".}

\item{dir}{A directory where you want to save the kmeans information to. The
character value can be a full path or relative to your current working directory.}

\item{regionacronym}{A character value supplying the region acronym. Currently,
only "EBSTS" and "WCGBTS" are supported.}

\item{strata}{A data frame specifying the strata.}

\item{nknots}{The number of knots you want in your spatial field.}
}
\value{
A list of spatial information used to run the model.
}
\description{
Set up the spatial information for a \link{[VAST]} run.
}
\author{
Kelli Faye Johnson
}
