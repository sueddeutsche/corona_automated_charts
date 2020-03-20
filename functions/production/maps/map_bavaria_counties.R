# This scrapes the official data for Bavarian counties and updates a map with it
chart_id <- "INSERT CHART ID HERE"
url_bavaria <- "https://www.lgl.bayern.de/gesundheit/infektionsschutz/infektionskrankheiten_a_z/coronavirus/karte_coronavirus/index.htm"

html_bavaria <- read_html(url_bavaria)

html_bavaria %>% 
  html_node("table") %>% 
  html_table() %>% 
  rename("Landkreis" = 1, "Zahl der Fälle" = "Anzahl der Fälle*") %>% 
  mutate(Landkreis = ifelse(Landkreis == "München", "München Land", Landkreis)) %>% 
  mutate(Landkreis = ifelse(Landkreis == "Augsburg", "Augsburg Land", Landkreis)) %>%
  left_join(translation_by_counties, by = c("Landkreis" = "Titel_LGL")) %>% 
  filter(!(Landkreis %in% c("unbekannt", "Gesamtergebnis"))) %>% 
  mutate(Titel = "") %>% 
  select(Lat, Lon, Titel, Landkreis, "Zahl der Fälle") -> df_bavaria_counties

# data needs to be pasted with semicolons, correct order has to be maintained: 
# Lat, Lon, Titel, Landkreis, Fälle
upload_df <- data.frame(apply(df_bavaria_counties, 1, paste, collapse = ";"))
names(upload_df) <- paste0(names(df_bavaria_counties), collapse = ";")

print("> Map Bavaria")

dw_data_to_chart(upload_df, chart_id = chart_id, api_key = API_KEY)

DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW))

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY, return_urls = FALSE)

httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))


  