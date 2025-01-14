# Kode 2
rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(reticulate)

# install sentence transformers dulu
# py_install("sentence_transformers")

# Load Python libraries in R
transformers <- reticulate::import("sentence_transformers")

# Load pre-trained sentence transformer model
# ini adalah model untuk embedding
model <- transformers$SentenceTransformer('naufalihsan/indonesian-sbert-large')

# sedangkan ini adalah model untuk qna
read_trans <- reticulate::import("transformers")
reader     <- read_trans$pipeline(task      = "question-answering",
                                  model     ="Rifky/Indobert-QA",
                                  tokenizer ="Rifky/Indobert-QA")



# kita ambil data
load("embed.rda")
complaints = komen

# lakukan embedding
complaint_embeddings <- model$encode(complaints)
embeddings_matrix <- as.matrix(reticulate::py_to_r(complaint_embeddings))

# sekarang kita akan buat function untuk pertanyaan langsung qna
mulai_donk = function(){
  pertanyaan = readline("Mau tanya apa: ")
  # embedding pertanyaan
  ques_embeddings <- model$encode(pertanyaan)
  ques_matrix <- as.matrix(reticulate::py_to_r(ques_embeddings))
  
  # mencari dokumen yang pas
  vec_a = ques_matrix[,1]
  jarak = rep(10,5)
  for(i in 1:5){
    vec_b    = embeddings_matrix[i,]
    jarak[i] = lsa::cosine(vec_a,vec_b)
  }
  # dokumen yang tepat
  dokumen = complaints[which.max(jarak)]
  # Provide model with question and context
  outputs <- reader(question = pertanyaan, context = dokumen)
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





