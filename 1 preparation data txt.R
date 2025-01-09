rm(list=ls())
gc()

set.seed(20921004)

# Load necessary libraries
library(dplyr)
library(readxl)
library(parallel)
library(tidytext)
ncore = detectCores()

# panggil semua stop words
stop = readLines("https://raw.githubusercontent.com/stopwords-iso/stopwords-id/master/stopwords-id.txt")

# kita bikin function untuk mengambil datanya
ambilin = function(input)

temp = readLines(input)
df   = data.frame(text = temp,
                  id   = 1:length(temp))





# Membaca data komentar dan melakukan preprocessing sederhana
setwd("~/RAG-using-R/raw story")
file  = list.files(pattern = "*txt")
df    = mclapply(file,readLines,mc.cores = ncore)
df    = data.table::rbindlist(df,fill = T) |> as.data.frame()




komen = df |> janitor::clean_names()
komen = komen |> pull(judul) |> unique() |> sort()

input = data.frame(id = 1:length(komen),text = komen)

pre_data =
  input %>%
  unnest_tokens("words",text) %>%
  filter(!words %in% stop) %>% 
  filter(stringr::str_length(words) > 3) %>% 
  group_by(id) %>% 
  summarise(komen = paste(words,collapse = " ")) %>% 
  ungroup()

komen = pre_data$komen

# save(komen,file = "to colab.rda")