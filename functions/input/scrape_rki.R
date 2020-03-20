#
# Scrape and save RKI's table each day
#
# RKI: https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html
# This script parses a HTML-table on the website of the RKI.
#

parseNumbersRki <- function(x) as.numeric(gsub("\\(\\d+\\)|\\.", "", x))

url_rki <- "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html"

html_rki <- read_html(url_rki)

html_rki %>%
  html_node("table") %>%
  html_table(header = FALSE) %>%
  .[3:nrow(.),] %>% 
  select(Bundesland = 1, `Fälle` = 2, `Differenz` = 3, `pro100000` = 4, `Todesfaelle` = 5) %>% 
  mutate_at(c("Fälle", "Fälle_elektronisch"), parseNumbersRki) %>% 
  select(Bundesland, `Fälle`) %>%
  left_join(translation_federal_state_latlon, by = c("Bundesland" = "federal_state")) %>%
  rename("Lon" = lon, "Lat" = "lat") %>%
  select(Lat, Lon, "Titel" = Bundesland, `Fälle`) %>%
  filter(Titel != "Gesamt") -> df_rki

rm(html_rki, parseNumbersRki, url_rki)