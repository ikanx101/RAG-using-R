library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(stringr)

rm(list=ls())

# load("~/RAG-using-R/4 RAG - blog deepseek/texts/teks.rda")
# 
# for(i in 1:360){
#   filename = paste0("teks",i,".txt")
#   sink(filename)
#   cat(artikel[[i]])
#   sink()
#   print(i)
# }

read_text_files <- function(folder_path) {
  files <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)
  texts <- purrr::map(files, function(file) {
    content <- readLines(file, warn = FALSE) %>% paste(collapse = " ")
    return(content)  # Mengembalikan vektor karakter langsung
  })
  names(texts) <- basename(files)  # Memberi nama berdasarkan nama file
  return(texts)
}

folder_path = "~/RAG-using-R/4 RAG - blog deepseek/texts"
# Baca file teks dengan fungsi yang sudah diperbaiki
text_data <- read_text_files(folder_path)

get_deepseek_embedding <- function(text, api_key, model = "deepseek-embedding", max_retries = 3) {
  url <- "https://api.deepseek.com/v1/embeddings"  # Pastikan endpoint benar
  
  for (i in 1:max_retries) {
    tryCatch({
      response <- httr::POST(
        url,
        httr::add_headers(
          "Authorization" = paste("Bearer", api_key),
          "Content-Type" = "application/json"
        ),
        body = jsonlite::toJSON(list(input = text, model = model), auto_unbox = TRUE),
        encode = "json"
      )
      
      if (httr::status_code(response) == 200) {
        return(unlist(httr::content(response)$data[[1]]$embedding))
      } else {
        warning(paste("Attempt", i, "failed with status:", httr::status_code(response)))
      }
    }, error = function(e) {
      warning(paste("Attempt", i, "errored:", e$message))
    })
    
    if (i < max_retries) Sys.sleep(2^i)  # Exponential backoff
  }
  
  stop("Failed to get embedding after ", max_retries, " attempts")
}

# Dapatkan embedding untuk setiap dokumen
api_key <- "sk-24d2a5762f0841d0abcf39e018034d69"
embeddings <- purrr::map(text_data, function(content) {
  get_deepseek_embedding(content, api_key)
})

# Konversi ke matriks
embedding_matrix <- do.call(rbind, embeddings)




# Nama file sudah menjadi names dari list, jadi kita bisa gunakan:
rownames(embedding_matrix) <- names(text_data)
















get_deepseek_embedding <- function(text, api_key, model = "deepseek-embedding") {
  url <- "https://api.deepseek.com/v1/embeddings"  # Ganti dengan endpoint yang benar
  
  headers <- c(
    "Authorization" = paste("Bearer", api_key),
    "Content-Type" = "application/json"
  )
  
  body <- list(
    input = text,
    model = model
  )
  
  response <- httr::POST(
    url,
    httr::add_headers(.headers = headers),
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )
  
  if (httr::status_code(response) != 200) {
    stop(paste("Error:", httr::content(response, "text")))
  }
  
  embedding <- httr::content(response)$data[[1]]$embedding
  return(unlist(embedding))
}

# Ganti dengan API key Anda

# Baca file teks
text_data <- artikel

# Dapatkan embedding untuk setiap dokumen
embeddings <- purrr::map(text_data, function(doc) {
  get_deepseek_embedding(doc$content, api_key)
})

get_deepseek_embedding(text_data[1],api_key)


# Konversi ke matriks
embedding_matrix <- do.call(rbind, embeddings)

# Beri nama baris sesuai nama file
rownames(embedding_matrix) <- sapply(text_data, function(x) x$name)

# Simpan matriks
saveRDS(embedding_matrix, "text_embeddings_matrix.rds")
