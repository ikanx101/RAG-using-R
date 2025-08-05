rm(list=ls())
gc()

library(tidyverse)
library(stringr)
library(ellmer)
library(rvest)
library(stringr)

# Sys.setenv(DEEPSEEK_API_KEY="xxx")

prompt_viz = 
  stringr::str_squish("Kamu adalah expert dalam bahasa R dengan spesialisasi di Tidyverse. 
                       Berikan jawaban berupa coding visualisasi menggunakan library(ggplot2) tanpa penjelasan.
                       Berikan warna yang cerah dengan nuansa biru. 
                       Hilangkan tulisan ``` pada kode yang dikeluarkan")
chat_viz = chat_deepseek(system_prompt = prompt_viz)

prompt_nar = 
  stringr::str_squish("Kamu adalah expert dalam bahasa R dengan spesialisasi di Tidyverse. 
                       Berikan jawaban berupa coding yang jika dirun menghasilkan narasi dan jawaban atas pertanyaan yang ditanyakan.
                       Berikan coding tanpa penjelasan sama sekali.")
chat_nar = chat_deepseek(system_prompt = prompt_nar)

source("pembuat narasi.R")

file = "data WC.csv"
df   = read.csv(file)

info = generate_data_narrative(file)
cat(info)

input = readline("Mau tanya apa?")
tanya = paste0( "Saya bekerja dengan dataset dengan karakteristik berikut:\n",
                info,
               " buat skrip untuk ",
               input,
               "\n. Buat nama dataframe nya menjadi df dalam skrip.")

kode = chat_viz$chat(tanya)
sink("tes.R")
cat(kode)
sink()
source("tes.R")





chat_nar$chat(tanya)
