rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(rvest)

setwd("~/RAG-using-R/4 RAG - blog deepseek")

elemen = ".page__content p"
load("url.rda")

link = temp

ambil_teks = function(i){
  baca  = link[i] %>% read_html()
  laman = baca %>% html_nodes(elemen) %>% html_text()
  laman = gsub("\\\n","",laman)
  laman = stringr::str_squish(laman)
  laman = paste(laman,collapse = " ")
  laman = stringr::str_squish(laman)
  return(laman)
}

artikel = c()
for(i in 1:length(link)){
  new_    = ambil_teks(i)
  # Sys.sleep(.5)
  artikel = c(new_,artikel)
  print(i)
}
save(artikel,file = "~/RAG-using-R/4 RAG - blog deepseek/texts/teks.rda")
