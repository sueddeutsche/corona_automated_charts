# read_data.R

##
#
## Translation Tables for geographical information is loaded first, becouse
# other datasets rely on translations
##

# German federal states with added Lat/Lon
translation_federal_state_latlon <- read_csv("input/translation/bundesland_lat_lon_translation.csv")

# Bavarian Counties to Lat/Lon (for map_bavaria_counties.R)
translation_by_counties <- read_csv("input/translation/by_counties_lat_lon_translation.csv")

# German Counties from English to German // NOT NEEDED RIGHT NOW
# translation_county_en_de <- read_csv("input/translation/county_en_to_de_translation.csv")


#######################################################################################


##
#
## Geographical spread around Germany and Bavaria
# is loaded secondly, becouse other datasets get subsetted with sz_sum_germany
##

# World-Data is already included in the data from Johns Hopkins above

#
## Robert-Koch-Institut: Cases per German Bundesland Current data on
# Federal-State-level parsed regularly to build up a dataset of historic spread
# around the German Federal States.

source("functions/input/scrape_rki.R") 
# returns -> df_rki

#
## SZ-Research: Cases per German Bundesland
# Current data on Federal-State-level
#

source("functions/input/read_sz_research.R")
# returns -> df_german_states and -> data_sz_historic

#
## OPTIONAL in the future: Coronavirus.jetzt
# Historic and current data n German County-level
#

# df_landkreise <- read.csv("https://raw.githubusercontent.com/iceweasel1/COVID-19-Germany/master/germany_with_source.csv")


#######################################################################################


##
#
## Numbers of Infections, Deaths, Recovered
#
##

#
## Johns Hopkins
# Historic and current data
#

# Historic data

# TODO: rename with historic
corona_confirmed_cases_historical <- read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")
corona_deaths_historical <- read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")
corona_recovered_historical <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")

# Current data

source("functions/input/read_jh_csse.R")
# returns -> df_corona_current and -> timestamp_jh_csse_max, -> source_credit_hopkins_worldometer, -> source_credit_hopkins_worldometer_url

# create longform data

corona_recovered_historical %>% 
  tidyr::pivot_longer(., cols = c(`1/22/20`:last_col()), names_to = "date", values_to = "total_cured") -> df_long_corona_recovered_historical

corona_deaths_historical %>% 
  tidyr::pivot_longer(., cols = c(`1/22/20`:last_col()), names_to = "date", values_to = "total_died") -> df_long_corona_died_historical

#
## FALLBACK: Worldometer
# Current data only if Johns Hopkins failes
#

if (!successful) {
  print("+++ John Hopkins failing. Using Worldometer instead +++")
  source("functions/input/scrape_worldometer.R")
}
# returns -> df_corona_current and -> source_credit_hopkins_worldometer, -> source_credit_hopkins_worldometer_url


#######################################################################################

rm(r, response, sheet_id, successful)
#######################################################################################
#######################################################################################