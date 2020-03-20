# This script creates output dumps in output/data/

## csv which logs the sz_sum_germany each hour
tibble(TIMESTAMP_NOW, sz_sum_germany) %>% 
  write_csv("output/data/germany_hourly_sums.csv", append = TRUE)

# write rki data
df_rki %>% 
  mutate(timestamp = TIMESTAMP_NOW) %>% 
  write_csv("output/data/rki_hourly_laender.csv", append = TRUE)
