data_preparation <- function(data_source = "JHU", cases_deaths = "cases") {

  # Data preparation --------------------------------------------------------
  
  dta_raw = read_csv(here::here("outputs/raw_data.csv"), 
                     col_types = 
                       cols(
                         country = col_character(),
                         time = col_date(format = ""),
                         cases_sum = col_double(),
                         deaths_sum = col_double(),
                         cases_diff = col_double(),
                         deaths_diff = col_double(),
                         source = col_character()
                       ))
  
  dta <<- dta_raw %>%
    # rename
    rename(value = paste0(cases_deaths, "_sum")) %>% 
    rename(diff = paste0(cases_deaths, "_diff")) %>% 
    
    group_by(country) %>%
    mutate(days_after_100 = 0:(length(country)-1)) %>%

    # Create labels for last instance for each country
    group_by(country) %>%
    mutate(
      name_end =
        case_when(
          days_after_100 == max(days_after_100) ~ paste0(as.character(country), ": ", format(value, big.mark=","), " - ", days_after_100, " days"),
          TRUE ~ "")) %>% 
  

    arrange(time) %>%
    group_by(country) %>%
    mutate(days_after_100 = 
             case_when(
               is.na(days_after_100) ~ as.integer(lag(days_after_100) + 1),
               TRUE ~ days_after_100),
           diff = value - lag(value),
           name_end = 
             case_when(
               is.na(name_end) ~ "",
               TRUE ~ name_end)) %>% 
    ungroup() %>%   # Create labels for last instance for each country
    group_by(country) %>% 
    mutate(
      name_end = 
        case_when(
          days_after_100 == max(days_after_100) ~ paste0(as.character(country), ": ", format(value, big.mark=","), " - ", days_after_100, " days"),
          TRUE ~ "")) %>% 
    mutate(highlight = country)
  
  

  # Menu vars ---------------------------------------------------------------
  
  V1_alternatives <<- dta %>%
    filter(value > 10) %>% 
    filter(!country %in% c("Total:")) %>% 
    arrange(desc(value)) %>% 
    distinct(country) %>% 
    pull(country)
  
  top_countries <<- dta %>%
    group_by(country) %>% 
    filter(value == max(value), 
           country != "Cruise Ship") %>% 
    distinct(country, value) %>% 
    ungroup() %>%
    top_n(n = 10, wt = value) %>% 
    filter(!country %in% c("Total:", "China")) %>% 
    arrange(desc(value)) %>% 
    pull(country)

}
