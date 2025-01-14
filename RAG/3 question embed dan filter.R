# Kode 3
# install.packages("lsa")

# kita akan hitung jarak antara pertanyaan dan data
# siapa yang paling dekat
pertanyaan = "Siapa nama ibu malin kundang?"
ques_embeddings <- model$encode(pertanyaan)
ques_matrix <- as.matrix(reticulate::py_to_r(ques_embeddings))

vec_a = ques_matrix[,1]
jarak = rep(10,5)
for(i in 1:5){
  vec_b    = embeddings_matrix[i,]
  jarak[i] = lsa::cosine(vec_a,vec_b)
}

dokumen = complaints[which.max(jarak)]

save(pertanyaan,dokumen,file = "to qna.rda")

