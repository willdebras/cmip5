library(data.table)
library(dplyr)
library(stringr)

filelist <- list.files("output")

test <- function(file) {
  
  data.table::fread
  
}

aggd_data <- lapply(filelist, function(x) data.table::fread(paste0("output/", x)))

names(aggd_data) <- filelist

clean_ind <- function(x) {
  
  temp_data <- x %>%
    dplyr::mutate(year = as.numeric(year)) %>%
    dplyr::filter(year > 1950) %>%
    dplyr::select(year, mean)
  
}


aggd_clean <- lapply(aggd_data, clean_ind)

full_file <- rbindlist(aggd_clean, idcol = "id") %>% 
  dplyr::mutate(modelgroup = case_when(
    stringr::str_detect(id, "rcp26") ~ "rcp26",
    stringr::str_detect(id, "rcp45") ~ "rcp45",
    stringr::str_detect(id, "rcp60") ~ "rcp60",
    stringr::str_detect(id, "rcp85") ~ "rcp85",
    stringr::str_detect(id, "historical") ~ "historical",
    TRUE ~ "Other"
  ))

full_nohist <- full_file %>%
  dplyr::filter(!modelgroup %in% "historical")


fwrite(full_file, "output/all_cmip5_models.csv")

fwrite(full_nohist, "output/all_cmip5_models_rcp2685.csv")
