##
# Map for German Federal States
# using SZ's Google sheet
#

chart_id <- "INSERT CHART ID HERE"

df_german_states %>% 
  rename(Titel = Bundesland) %>% 
  mutate(description = ifelse(Art == "Bestätigte Fälle bislang (auch die wieder gesunden)",
                              paste0(Werte, " Fälle"),
                              paste0(Werte, " Todesfälle"))) %>% 
  mutate(Art = ifelse(Art == "Bestätigte Fälle bislang (auch die wieder gesunden)", "Bestätigte Fälle", Art)) %>% 
  filter(description != "NA Todesfälle") -> df_german_states

# data needs to be pasted with semicolons, correct order has to be maintained: 
# Lat, Lon, Titel (aka Bundesland), Fälle
upload_df <- data.frame(apply(df_german_states, 1, paste, collapse = ";"))
names(upload_df) <- paste0(names(df_german_states), collapse = ";")

print("> Map German States 1/2")

dw_data_to_chart(upload_df, chart_id = chart_id, api_key = API_KEY)

DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))
