# This script creates and updates a table, that shows infections, deaths and recovered numbers in
# Italy, Germany and worldwide

chart_id <- "INSERT CHART ID HERE"

bind_rows(
  df_corona_current %>% 
    filter(Land %in% c("China", "Deutschland", "Italien")) %>% 
    rowwise() %>% 
    arrange(Infizierte) %>% 
    select(Land, Infizierte, Genesene, Verstorbene),
  
  df_corona_current %>% 
    filter(Land != "Total:") %>% 
    mutate(Land = "Weltweit") %>% 
    group_by(Land) %>% 
    summarise(Infizierte = sum(Infizierte, na.rm = T),
              Genesene = sum(Genesene, na.rm = T),
              Verstorbene = sum(Verstorbene, na.rm = T)) 
) -> df_table_cases_deaths_recovered

DatawRappr::dw_data_to_chart(df_table_cases_deaths_recovered, chart_id = chart_id, api_key = API_KEY)
DatawRappr::dw_edit_chart(chart_id = chart_id, api_key = API_KEY, 
                          annotate = paste0("Letzte Aktualisierung: ", TIMESTAMP_NOW),
                          source_name = source_credit_hopkins_worldometer,
                          source_url = source_credit_hopkins_worldometer_url)

DatawRappr::dw_publish_chart(chart_id, api_key = API_KEY,
                             return_urls = FALSE)

# hardcoded here - should be fixed in current version of DatawRappr 1.1.1
httr::handle_reset(paste0("https://api.datawrapper.de/v3/charts/", chart_id))
