# create_line_cases.R
#
# this script creates a line chart with the cum sum of all registered cases
# and sends it to Datawrapper (chart_id = rhdL0)
#
chart_id <- "INSERT CHART ID HERE"

corona_confirmed_cases_historical %>%
  tidyr::pivot_longer(., cols = c(`1/22/20`:last_col()), names_to = "date", values_to = "total") %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"),
         is_china = ifelse(`Country/Region` == "China", "China", "Rest der Welt")) %>%
  select(date, total, is_china) %>%
  group_by(date, is_china) %>%
  summarise(total = sum(total, na.rm = T)) %>%
  tidyr::pivot_wider(., names_from = is_china, values_from = total) %>% 
  rename(Datum = date) -> df_corona_confirmed_date

DatawRappr::dw_data_to_chart(df_corona_confirmed_date, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))

