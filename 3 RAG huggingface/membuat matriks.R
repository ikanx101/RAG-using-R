# Install package jika belum ada
if (!requireNamespace("reticulate", quietly = TRUE)) {
  install.packages("reticulate")
}

library(reticulate)

# Setup Python environment (pastikan sudah ada Python 3.7+ terinstall)
# Anda mungkin perlu menyesuaikan path Python Anda
# py_discover_config() # Untuk melihat konfigurasi Python yang tersedia

# Install package Python yang diperlukan
py_install("sentence-transformers", pip = TRUE)
py_install("torch", pip = TRUE)

# Import modul Python
st <- import("sentence_transformers")
np <- import("numpy")

# Fungsi untuk mengubah teks menjadi matriks embedding
text_to_matrix <- function(texts, model_name = "all-MiniLM-L6-v2") {
  # Inisialisasi model
  model <- st$SentenceTransformer(model_name)
  
  # Encode teks menjadi embedding
  embeddings <- model$encode(texts)
  
  # Konversi ke matriks R
  matrix <- np_array(embeddings, dtype = "float32")
  
  return(matrix)
}

# Contoh penggunaan
teks <- c(
  "Ini adalah contoh kalimat pertama.",
  "Kalimat kedua memiliki makna yang berbeda.",
  "Dan ini adalah contoh ketiga."
)

# Dapatkan matriks embedding
embedding_matrix <- text_to_matrix(teks)

# Tampilkan hasil
print(dim(embedding_matrix))  # Dimensi matriks: jumlah dokumen x dimensi embedding
print(head(embedding_matrix))

# Untuk model lain yang tersedia di HuggingFace:
# embedding_matrix <- text_to_matrix(teks, "paraphrase-multilingual-MiniLM-L12-v2")