# main.R
#
# This is the main.R - that is called by the cronjob to run all scripts
#

print(paste0("+++ Started at: ", Sys.time()))

# loading libraries with needs. Install it first, if needed:
# install.packages("needs")
library(needs)

needs(
  tidyverse, magrittr, rvest, clipr,
  zoo, scales, tidyr, readxl, DatawRappr,lubridate, 
  jsonlite, countrycode, stringr, dplyr, googlesheets4, lubridate, here
  )

# manually set working directory, to get the right references for the scripts
# if you're a pro, you could use here::here()
# setwd("~/scripts/corona")

# create timestamp for updating the information in Datawrapper, wrangle it to German date format.
TIMESTAMP_NOW <- format(Sys.time(), "%d.%m.%Y %H:%M Uhr")

# set API-Key for Datawrapper globally:
API_KEY <- "INSERT YOUR DATWRAPPER-API KEY HERE"

# load misc functions
source("functions/misc.R")

print(">>> Loading data")
source("functions/input/read_data.R")

print(">>> Creating Dashboard")

source("functions/production/dashboard/create_dashboard.R")

print(">>> Creating Charts")

# Table with Germany, Italy, China and World
source("functions/production/charts/table_cases_deaths_recovered.R")

# Table with all Cases world-wide
source("functions/production/charts/table_world_cases_deaths.R")

# Line-chart with cum-sum of Cases: World vs. China
source("functions/production/charts/line_cases.R")

# Area-chart with cum-sums: Cases vs. Cured vs. Deaths worldwide
source("functions/production/charts/area_cases_vs_cured.R")

# Bar-chart with percentages: Deathrates by country
source("functions/production/charts/bar_deathrate.R")

# Line-chart: Comparison of Cases between Corona and Sars in days since first occurence
source("functions/production/charts/line_corona_vs_sars.R")

print(">>> Creating Maps")

source("functions/production/maps/get_geographical_data.R")

# map Cases in Bavarian counties
source("functions/production/maps/map_bavaria_counties.R")

print(">>> Creating Output")

# create output datasets
source("functions/create_output_data.R")

print(paste("+++ Finished Script at", Sys.time()))

print(paste("+++++++++++++++++++++++++++++++++"))
