# Kode 2
rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(reticulate)
library(ellmer)
library(ragnar)

# pemanggilan deepseek
Sys.setenv(DEEPSEEK_API_KEY="")

chat_deepseek(
  system_prompt = NULL,
  base_url = "https://api.deepseek.com",
  # api_key = deepseek_key(),
  model = NULL,
  seed = NULL,
  api_args = list(),
  echo = NULL,
  api_headers = character()
)

chat_1 <- chat_deepseek()

# install sentence transformers dulu
# py_install("sentence_transformers")

# setting transformers
# bikin object transformers
transformers = reticulate::import("sentence_transformers")

# model pertama - transformers
nama_model = "Thugpou/AES-Indonli-Improved"
# nama_model = "naufalihsan/indonesian-sbert-large"
model = transformers$SentenceTransformer(nama_model)


# kita ambil data
load("~/RAG-using-R/4 RAG - blog deepseek/texts/teks.rda")
complaints = artikel

# lakukan embedding
complaint_embeddings = model$encode(complaints)
embeddings_matrix    = as.matrix(reticulate::py_to_r(complaint_embeddings))

# sekarang kita akan buat function untuk pertanyaan langsung qna
mulai_donk = function(){
  pertanyaan = readline("Mau tanya apa: ")
  
  ques_embeddings <- model$encode(pertanyaan)
  ques_matrix <- as.matrix(reticulate::py_to_r(ques_embeddings))
  
  # mencari dokumen yang pas
  vec_a = ques_matrix[,1]
  jarak = rep(10,length(artikel))
  for(i in 1:length(artikel)){
    vec_b    = embeddings_matrix[i,]
    jarak[i] = lsa::cosine(vec_a,vec_b)
  }
  
  max_indices = rep(0,3)
  for (i in 1:3) {
    max_index      = which.max(jarak)  # Find the index of the maximum value
    max_indices[i] = max_index  # Store the index
    jarak          =  jarak[-max_index]  # Remove the maximum value to find the next one
  }
  
  # dokumen yang tepat
  dokumen = complaints[max_indices]
  dokumen = paste(dokumen,collapse = ". ")
  
  prompt = paste0("Berdasarkan informasi ini: ",
                  dokumen,
                  "Tanpa mengambil data yang selain informasi di atas.",
                  "Jawablah pertanyaan ini: ",pertanyaan,
                  "Tampilkan jawaban secara sederhana dan lugas. Buat dalam maksimal 3 paragraf tanpa melibatkan formula matematika."
                  )
  
  output = chat_1$chat(prompt)
  
  return(output)
}


# ini sebagai set awal
ulang = T
# kita bikin loop dulu deh ya
while(ulang){
  mulai_donk()
  ulang_gak = readline(prompt = "Tanya lagi? (Y/N) ")
  ulang     = ifelse(ulang_gak == "Y",T,F)
  cat("\014")
}

