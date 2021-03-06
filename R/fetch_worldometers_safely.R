fetch_worldometers_safely <- 
  purrr::safely(
    
    function() {

      # DEBUG
      # source(here::here("R/download_or_load.R"))

      download_or_load("outputs/temp_worldometers.html", URL = "https://www.worldometers.info/coronavirus/#countries")
      
      raw_web = read_html(here::here("outputs/temp_worldometers.html"))  
      table_countries_raw = html_table(raw_web)[[1]]
      
      time_worldometer <<- stringr::str_extract(string = html_text(raw_web),
                                                pattern = '\\w+\\s\\d+(st)?(nd)?(rd)?(th)?,\\s+\\d+, \\d+:\\d+ GMT')
      
      # Select variable to use
      # variable_to_use = "TotalCases"
      # if (cases_deaths == "deaths") variable_to_use = "TotalDeaths"
      
      
      table_countries = table_countries_raw %>% 
        as_tibble() %>%
        rename(country = `Country,Other`,
               cases_sum = TotalCases,
               deaths_sum = TotalDeaths) %>% 
        mutate(time = as.Date(time_worldometer, "%b %d, %Y"),
               cases_sum = as.numeric(gsub(",", "", cases_sum)),
               deaths_sum = as.numeric(gsub(",", "", deaths_sum))) %>% 
        select(country, time, cases_sum, deaths_sum) %>%
        mutate(
          country = 
            case_when(
              country == "S. Korea" ~ "South Korea",
              country == "Taiwan*" ~ "Taiwan",
              country == "USA" ~ "US",
              country == "UK" ~ "United Kingdom",
              TRUE ~ country)) %>% 
        write_csv("outputs/raw_data_worldometers.csv")
      
      
    }
  )
