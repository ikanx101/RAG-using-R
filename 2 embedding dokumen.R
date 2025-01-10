Kode 2
rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(reticulate)

# untuk setting awal komputer coba lihat ini dulu
# https://ikanx101.com/blog/setting-hug/

# install sentence transformers dulu
# py_install("sentence_transformers")

# Load Python libraries in R
transformers <- reticulate::import("sentence_transformers")

# Load pre-trained sentence transformer model
model <- transformers$SentenceTransformer('naufalihsan/indonesian-sbert-large')

# kita ambil data
load("to colab.rda")
complaints = komen

complaint_embeddings <- model$encode(complaints)
embeddings_matrix <- as.matrix(reticulate::py_to_r(complaint_embeddings))

save(embeddings_matrix,file = "dokumen.rda")
