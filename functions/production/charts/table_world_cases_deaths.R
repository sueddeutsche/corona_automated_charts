# John Hopkins CSSE/Worldometer
chart_id <- "INSERT CHART ID HERE"

df_corona_current %>% 
  mutate(is_selected = ifelse(Land == "Italien", "Italien", "Rest der Welt"),
         is_selected = ifelse(Land == "China", "China", is_selected)) %>%
  group_by(Land) %>% 
  summarise(Infizierte = sum(Infizierte, na.rm = T),
            Genesene = sum(Genesene, na.rm = T),
            Verstorbene = sum(Verstorbene, na.rm = T)) %>% 
  mutate(Country_ID = countrycode(Land, origin = "country.name.de", destination = "iso3c")) %>% 
  arrange(desc(Infizierte)) %>% 
  filter(!is.na(Land)) %>% 
  select("Land", "Fälle" = Infizierte, "Todesfälle" = Verstorbene, Country_ID) -> df_corona_dw_worldometer

dw_data_to_chart(df_corona_dw_worldometer, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))