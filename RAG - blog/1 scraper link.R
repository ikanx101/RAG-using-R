rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(rvest)

url = c("https://ikanx101.com/",
        paste0("https://ikanx101.com/page",2:12,"/")
        )

elemen = ".no_toc a"

ambilin = function(i){
  target = url[i]
  baca   = target %>% read_html() 
  laman  = baca %>% html_nodes(elemen) %>% html_attr("href")
  laman  = paste0("https://ikanx101.com",laman)
  return(laman)
}

temp = c()
for(i in 1:12){
  temp_ = ambilin(i)
  Sys.sleep(4)
  print(i)
  temp = c(temp_,temp)
}

setwd("~/RAG-using-R/RAG - blog")
save(temp,file = "url.rda")
