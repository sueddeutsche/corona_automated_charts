# corona_cases_vs_cured.R
#
# this script creates a area chart with the sum of all registered cases and the cured and deceased
# and sends it to Datawrapper (chart_id = 9vAGe)
#

chart_id <- "INSERT CHART ID HERE"

corona_confirmed_cases_historical %>%
  tidyr::pivot_longer(., cols = c(`1/22/20`:last_col()), names_to = "date", values_to = "total_infected") %>% 
  left_join(df_long_corona_recovered_historical) %>% 
  left_join(df_long_corona_died_historical) %>% 
  mutate(date = as.Date(date, format = "%m/%d/%y")) %>% 
  arrange(date) %>% 
  group_by(date) %>% 
  summarise(sum_infected = sum(total_infected, na.rm = T),
            sum_cured = sum(total_cured, na.rm = T),
            sum_died = sum(total_died, na.rm = T),
            sum_active = sum_infected - sum_cured - sum_died
            ) %>% 
  select(-sum_infected) %>% 
  rename(Datum = date, Erkrankte = sum_active, Geheilte = sum_cured, Verstorbene = sum_died) -> df_corona_cases_vs_recovered

DatawRappr::dw_data_to_chart(df_corona_cases_vs_recovered, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))
