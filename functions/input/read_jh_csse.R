#
# Johns Hopkins current data from dashboard
# check to find out it there's an response from JH CSSE
successful <- FALSE

tryCatch(
  {
    r <- httr::RETRY("GET", url = "https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Z7biAeD8PAkqgmWhxG2A/FeatureServer/2/query?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc&resultOffset=0&resultRecordCount=200&cacheHint=true",
                     config = (httr::add_headers(
                       Referer = "https://www.arcgis.com/apps/opsdashboard/index.html",
                       "sec-fetch-dest" = "empty",
                       "sec-fetch-mode" = "cors",
                       "sec-fetch-site" = "same-site",
                       "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36"
                     )),
                     terminate_on = c(200, 201, 202, 203, 204))
    response <- jsonlite::fromJSON(httr::content(r, encoding = "UTF-8"))
    successful <- is_empty(response$error)
    
    df_corona_current <- response$features$attributes
    
    timestamp_jh_csse_max <- format(as.POSIXct(max(df_corona_current$Last_Update) / 1000, origin = "1970-01-01"), format = "%d.%m.%Y %H:%M Uhr")
    source_credit_hopkins_worldometer <- "Johns-Hopkins-Universität CSSE/SZ"
    source_credit_hopkins_worldometer_url <- "https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6"
  },
  error = function(cond) {
    message("There was an error when connecting to JH CSSE Dashboard")
    message("SKIPPING JD CSSH Dashboard in import!")
    message("Here's the original error message:")
    message(cond)
    # Choose a return value in case of error
    return(NA)
  }
)

# Prepare John Hopkins Data

df_corona_current %>% 
  mutate_at(c("Confirmed", "Deaths", "Recovered"), make_numeric) %>%
  select(Land = `Country_Region`, Infizierte = Confirmed, "Genesene" = Recovered, "Verstorbene" = Deaths) %>% 
  mutate(Land = countrycode::countrycode(Land, origin = "country.name", destination = "country.name.de")) %>% 
  mutate(Land = ifelse(Land == "Korea, Republik von", "Südkorea", Land)) %>% 
  mutate(Infizierte = ifelse(Land == "Deutschland", sz_sum_germany, Infizierte)) -> df_corona_current
