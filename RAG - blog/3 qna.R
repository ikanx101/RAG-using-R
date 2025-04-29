# Kode 2
rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(reticulate)

# install sentence transformers dulu
# py_install("sentence_transformers")

# setting transformers
# bikin object transformers
transformers = reticulate::import("sentence_transformers")

# model pertama - transformers
model = transformers$SentenceTransformer('naufalihsan/indonesian-sbert-large')

# sedangkan ini adalah model kedua untuk melakukan QnA
read_trans = reticulate::import("transformers")
reader     = read_trans$pipeline(task      = "question-answering",
                                 model     ="Rifky/Indobert-QA",
                                 tokenizer ="Rifky/Indobert-QA")

read_r = read_trans$pipeline(task      = "question-answering",
                             model     ="deepset/roberta-base-squad2",
                             tokenizer ="deepset/roberta-base-squad2")
  
# kita ambil data
load("~/RAG-using-R/RAG - blog/texts/teks.rda")
complaints = artikel

# lakukan embedding
complaint_embeddings = model$encode(complaints)
embeddings_matrix    = as.matrix(reticulate::py_to_r(complaint_embeddings))

# sekarang kita akan buat function untuk pertanyaan langsung qna
mulai_donk = function(){
  pertanyaan = readline("Mau tanya apa: ")
  # embedding pertanyaan
  ques_embeddings <- model$encode(pertanyaan)
  ques_matrix <- as.matrix(reticulate::py_to_r(ques_embeddings))
  
  # mencari dokumen yang pas
  vec_a = ques_matrix[,1]
  jarak = rep(10,349)
  for(i in 1:349){
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
  
  # Provide model with question and context
  outputs = reader(question = pertanyaan, context = dokumen)
  # outputs = read_r(question = pertanyaan, context = dokumen)
  outputs %>% as_tibble() %>% pull(answer) %>% print()
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

