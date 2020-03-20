# corona_vs_sars.R
#
# Creates a line chart that compares the cases of corona and SARS by day since first occurence.
# and sends it to Datawrapper (chart_id = "sXaz7")
#
chart_id <- "INSERT CHART ID HERE"

# load prepared SARS data from WHO
WHO_sars_totals <- readRDS("input/processed/WHO_sars_totals.RData")

# prepare virus data - calculate dates to days since first occurence

# wrangle Corona (since Dec 1st 2019)
corona_confirmed_cases_historical %>%
  pivot_longer(cols = c(`1/22/20`:last_col()), names_to = "date", values_to = "total") %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"),
         days = date - as.Date("2019-12-01")) %>%
  select(date, days, total) %>%
  group_by(days, date) %>%
  summarise(total = sum(total, na.rm = T)) %>%
  bind_rows(tibble(days = 0, total = 0),.) %>%
  complete(days = full_seq(days, 1)) %>%
  mutate(total = na.locf(total), virus = "Coronavirus") -> df_corona_days

# wrangle Sars (since Nov 27 2002)
WHO_sars_totals %>%
  mutate(days = date - as.Date("2002-11-27")) %>%
  bind_rows(tibble(days = 0, total = 0),.) %>%
  filter(total <= 8096 & days <= 200) %>%
  complete(days = full_seq(days, 1)) %>%
  mutate(total = na.locf(total), virus = "SARS") -> df_sars_days

bind_rows(df_corona_days, df_sars_days) %>%
  select(-date) %>%
  pivot_wider(names_from = virus, values_from = total) -> df_corona_vs_sars

DatawRappr::dw_data_to_chart(df_corona_vs_sars, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))
