# scraper

library(xml2)
library(rvest)
library(utils)
library(data.table)

cmip_archive <- xml2::read_html("http://climexp.knmi.nl/CMIP5/Tglobal/index.cgi") %>% rvest::html_nodes("a") %>% rvest::html_attr("href")

cmip_links <- paste0("http://climexp.knmi.nl/CMIP5/Tglobal/", cmip_archive)



model_cleanup <- function(link) {
  
  temp_obj <- utils::read.delim2(link, skip = 3, header = F, sep = "") %>%
    `colnames<-`(c("year", "jan", "feb", "mar", "april", "may", "june", "july", "aug", "sep", "oct", "nov", "dec"))
  
  temp_obj[1:13] <- lapply(temp_obj[1:13], as.numeric)
  
  temp_obj$mean <- rowMeans(temp_obj[,2:13], na.rm=TRUE)
  
  return(temp_obj)
  
}

model_name <- function(link) {
  
  return(stringr::str_match(link, "Amon_\\s*(.*?)\\s*.dat")[2])
  
}



read_write_files <- function(list) {
  
  
  models <- lapply(list, function(x) model_cleanup(x))
  
  names(models) <- unlist(lapply(list, model_name))
  
  lapply(names(models), function(x) data.table::fwrite(models[[x]], file = paste0("output/", x, ".csv")))
  
  
}

read_write_files(cmip_links)
