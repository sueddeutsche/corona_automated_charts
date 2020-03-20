#
## SZ-Research: Cases per German Bundesland
# Current data on Federal-State-level
#
# SZ reporters collect and combine multiple data sources 
# to calculate our own sum of official cases in Germany and its States.
#

sheets_deauth()

sheet_id <- "INSERT SHEET ID HERE"
data_sz <- sheets_read(sheet_id, skip = 2)

data_sz %>% 
  filter(!is.na(Lat)) %>% 
  select(1:5) %>% 
  pivot_longer(cols = c(4:5), names_to = "Art", values_to = "Werte") -> df_german_states

# get sum of all German Cases
sz_sum_germany <- sum(subset(df_german_states, Art == "Bestätigte Fälle bislang (auch die wieder gesunden)")$Werte)

# Sum Germany last days
data_sz_historic <- read_csv("output/data/germany_hourly_sums.csv", col_names = c("timestamp", "confirmed"))
data_sz_historic %<>% 
  mutate(date = as.Date(timestamp, format = "%d.%m.%Y %H:%M")) %>% 
  group_by(date) %>% 
  arrange(desc(confirmed)) %>%
  distinct(date, .keep_all = TRUE)