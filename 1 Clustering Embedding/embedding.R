rm(list=ls())
gc()

# Load necessary libraries
library(reticulate)
library(readr)
library(dplyr)

# Load Python libraries in R
transformers <- reticulate::import("sentence_transformers")

# Load pre-trained sentence transformer model
# model <- transformers$SentenceTransformer('all-MiniLM-L6-v2')
model <- transformers$SentenceTransformer('firqaaa/indo-sentence-bert-base')

# ambil data komplen
complaints = readLines("komplen.txt")
str(complaints)

# melakukan embedding
complaint_embeddings <- model$encode(complaints)

# bikin matriks embedding
embeddings_matrix <- as.matrix(reticulate::py_to_r(complaint_embeddings))


