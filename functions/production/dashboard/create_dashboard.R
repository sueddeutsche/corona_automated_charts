# create_dashboard.R
#
# this script creates a dashboard, calculating current doubling rate, which might be used on our homepage
#

chart_id <- "INSERT CHART ID HERE"

# check if we have current data from today:

country_cases_today <-
  df_corona_current %>% 
  group_by(Land) %>% 
  mutate(Infizierte = sum(Infizierte)) %>% 
  select('Country' = Land, Cases = 'Infizierte') %>% 
  unique() %>% 
  mutate(Date = Sys.Date()) %>% 
  mutate(Cases = ifelse(Country == "Deutschland", sz_sum_germany, Cases)) %>% # change sum from SZ research
  select(Country,Date,Cases)
  
# append current with historical data,
# countrycode data to German,
# then calculate Growth rate by comparing daily sums per country,
# derive doubling rate from growth rate, and calculate the doubling change.
country_cases <-
  corona_confirmed_cases_historical %>%
  pivot_longer(names_to = 'Date', values_to = 'Cases', cols = 5:ncol(.)) %>%
  select('Province' = 1, 'Country' = 2, Date, Cases) %>%
  mutate(Country = countrycode(Country, origin = "country.name", destination = "country.name.de"),
         Country = ifelse(Country == "Korea, Republik von", "Südkorea", Country)) %>% 
  mutate(Date = mdy(Date)) %>%
  group_by(Country, Date) %>%
  mutate(Cases = sum(Cases)) %>%
  select(-Province) %>%
  unique() %>% 
  rbind(country_cases_today) %>% 
  # mutate(Cases = ifelse(Country == "Deutschland" & Date %in% sz_research_dates, unlist(data_sz_historic[which(data_sz_historic$date == Date), "confirmed"]), Cases)) %>% 
  group_by(Country) %>% 
  arrange(Date) %>% 
  mutate(
    Added_Cases = Cases - lag(Cases),
    Growth_Factor = Added_Cases / lag(Added_Cases),
    Added_Cases_Three_Days = Cases - lag(Cases,n=5),
    Growth_Rate =  (1 + Added_Cases_Three_Days / lag(Cases, n = 5)) %>% round(3),
    Doubling = (log(2) / log(Growth_Rate) * 5) %>% round(2),
    Doubling_Change = (Doubling - lag(Doubling)) / lag(Doubling)
  ) %>% 
  ungroup()

# add a flag icon for each country in Datawrapper,
# add different trend indicator icons depending ob the Doubling-Change-variable.
dashboard <-
  country_cases %>% 
  mutate(
    country_flag = paste0(":", tolower(countrycode(Country, origin = "country.name.de", destination = "iso2c")), ":"),
    Country = ifelse(Country == "Korea, Republik von", "Südkorea", Country)
  ) %>% 
  filter(Date == max(Date)) %>%
  mutate(
    Doubling = round(Doubling,1),
    Trend = 
      ifelse(Doubling_Change < -.2,"&#9679;&#9679;&#9679;",
             ifelse(Doubling_Change <= .2,"&#9679;&#9679;&#9675;","&#9679;&#9675;&#9675;")),
    Doubling_Color =
      ifelse(Doubling <= 4,"rot",
             ifelse(Doubling <= 7,"orange",
                    ifelse(Doubling <= 14,"gelb","grün")))
  ) %>% 
  select(country_flag, Country,Cases,Added_Cases,Doubling,Trend,Doubling_Color)

# filter dashboard countries, set up dashboard with German descriptions
dashboard %>% 
  filter(Country %in% c("Italien","Deutschland","Südkorea","Vereinigte Staaten","Frankreich","Spanien","Österreich")) %>% 
  mutate(Country = paste0(country_flag, " ", Country)) %>% 
  arrange(desc(Cases)) %>% 
  mutate(Doubling = paste0(Doubling," Tage")) %>% 
  select("Land" = country_flag, "Staat" = Country, 'Bestä&shy;tigte Fälle' = 3, 'Neu' = 4, 'Ver&shy;dopp&shy;lung' = 5, 'Trend' = Trend,Doubling_Color) -> df_corona_dashboard

DatawRappr::dw_data_to_chart(df_corona_dashboard, chart_id = chart_id, api_key = API_KEY)

DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0(
                            "Die Verdopplungszeit gibt an, wie schnell sich die Epidemie ausbreitet. 
                            Der Trend zeigt an, wie sich dieses Tempo verändert: 
                            wird langsamer &#9679;&#9675;&#9675;, bleibt gleich &#9679;&#9679;&#9675;, wird schneller &#9679;&#9679;&#9679;. 
                            Letzter Stand der Daten: ", ifelse(!is.na(timestamp_jh_csse_max), timestamp_jh_csse_max, TIMESTAMP_NOW)),
                          source_name = source_credit_hopkins_worldometer,
                          source_url = source_credit_hopkins_worldometer_url)

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))

