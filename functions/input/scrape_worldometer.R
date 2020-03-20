#
# Scrape and save Worldometers table each day
#
# Url: https://www.worldometers.info/coronavirus/
#

html_file <- read_html("https://www.worldometers.info/coronavirus/")

html_file %>% 
  html_node("#main_table_countries") %>% 
  html_table() -> df_corona_worldometer_table

df_corona_worldometer_table %>% 
  select(`Country/Region` = "Country,Other", sum_infected = TotalCases, sum_deaths = TotalDeaths,
         sum_recovered = TotalRecovered) %>% 
  mutate_at(c("sum_infected", "sum_deaths", "sum_recovered"), make_numeric) %>% 
  rename(Land = `Country/Region`, Infizierte = sum_infected, "Genesene" = sum_recovered, Verstorbene = sum_deaths) %>% 
  mutate(Land = countrycode::countrycode(Land, origin = "country.name", destination = "country.name.de")) %>% 
  mutate(Land = ifelse(Land == "Korea, Republik von", "Südkorea", Land)) %>% 
  mutate(Infizierte = ifelse(Land == "Deutschland", sz_sum_germany, Infizierte)) -> df_corona_current

source_credit_hopkins_worldometer <- "Worldometers/SZ"
source_credit_hopkins_worldometer_url <- "https://www.worldometers.info/coronavirus/"
