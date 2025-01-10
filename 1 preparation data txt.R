# Kode 1
rm(list=ls())
gc()

set.seed(20921004)

# Load necessary libraries
library(dplyr)
library(readxl)
library(parallel)
library(tidytext)
ncore = detectCores()

# Membaca data komentar dan melakukan preprocessing sederhana
setwd("~/RAG-using-R/raw story")
file  = list.files(pattern = "*txt")

# kita bikin function untuk mengambil datanya
# input = file[[1]]
ambilin = function(input){
  # pengambilan data
  temp = readLines(input)
  temp = paste(temp,collapse = "")
  return(temp)
}
# kita ambil semua data yang ada
df = mclapply(file,ambilin,mc.cores = ncore) |> unlist()

# kita akan save menjadi data yang ready
setwd("~/RAG-using-R")
komen = df
save(komen,file = "to colab.rda")
