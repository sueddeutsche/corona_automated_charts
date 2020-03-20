# corona_deaths_vs_cases.R
#
# Creates a bar chart that compares the cases and deaths of corona by country. 
#
chart_id <- "INSERT CHART ID HERE"

corona_cases_per_country <-
  corona_confirmed_cases_historical %>%
  pivot_longer(., names_to = 'Date', values_to = 'Cases', cols = 5:ncol(.)) %>%
  select('Province' = 1, 'Country' = 2, Date, Cases) %>%
  mutate(Date = mdy(Date)) %>%
  group_by(Country, Date) %>%
  mutate(Cases = sum(Cases)) %>%
  select(-Province) %>%
  unique()

corona_deaths_historical %>% 
  pivot_longer(names_to = 'Date', values_to = 'Cases', cols = 5:ncol(.)) %>%
  select('Province' = 1, 'Country' = 2, Date, Cases) %>%
  mutate(Date = mdy(Date)) %>%
  group_by(Country,Date) %>%
  mutate(Cases = sum(Cases)) %>%
  select(-Province) %>%
  unique() %>% 
  select(Country,Date,'Deaths' = 3) %>% 
  left_join(corona_cases_per_country) %>% 
  ungroup() %>% 
  group_by(Country) %>% 
  filter(Date == max(Date), Deaths > 0) %>% 
  mutate(Death_Rate = (Deaths / Cases * 100) %>% round(1)) %>% 
  arrange(desc(Death_Rate)) %>% 
  select(Country,Death_Rate) %>% 
  filter(Country != "Others") %>%
  mutate(Country_DE = countrycode(Country, origin = "country.name", destination = "country.name.de")) %>% 
  ungroup() %>% 
  mutate(Country_DE = ifelse(Country_DE == "Korea, Republik von", "Südkorea", Country_DE)) %>% 
  select('Country' = Country_DE,Death_Rate) %>% 
  rename(Land = Country, Sterberate = Death_Rate) -> df_corona_deaths

DatawRappr::dw_data_to_chart(df_corona_deaths, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))
