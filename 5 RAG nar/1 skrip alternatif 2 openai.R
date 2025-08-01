rm(list=ls())
gc()

library(ragnar)
library(dplyr)
library(stringr)
library(ellmer)
library(rvest)
library(stringr)

setwd("~/RAG-using-R/5 RAG nar")

Sys.setenv(OPENAI_API_KEY="")
Sys.setenv(DEEPSEEK_API_KEY="")

load("url.rda")
pages = temp

# Create and connect to a vector store
store_location = "ikanx101.com.duckdb"
store = ragnar_store_create(
  store_location,
  embed = \(x) ragnar::embed_openai(x, model = "text-embedding-3-small")
)

# Read each website and chunk it up
for (i in 323:length(pages)) {
  message("ingesting: ", pages[i])
  chunks = 
    pages[i] |>
    read_as_markdown() |>
    markdown_chunk(
      target_size = NA,
      segment_by_heading_levels = 3
    ) |>
    filter(str_starts(text, "### ")) 
  
  ragnar_store_insert(store, chunks)
}

# Build the index
ragnar_store_build_index(store)

# connect into data
store = ragnar_store_connect(store_location, read_only = TRUE)

# ini sebagai contoh kalau kita mau ambil topik relevan dari pertanyaan
# menggunakan ragnar dan duckdb

# masukkan pertanyaan
text = readline("Mau tanya apa? ")

# ambil relevant chunk
relevant_chunks = ragnar_retrieve_vss(
  store,
  text,
  top_k = 2 # ambil top 3 konten yang paling relevan
)

relevant_chunks$origin  %>% unique()
relevant_chunks$context %>% unique()


# alternatif 1
prompt_ = stringr::str_squish(
  "Berdasarkan informasi yang diberikan, jawablah pertanyaan ini dengan SYARAT berikut ini:
   ATURAN UTAMA: 
                  1. Dilarang menggunakan knowledge pada OpenAI.
                  2. Hanya gunakan informasi yang diberikan. 
                  3. Tampilkan jawaban secara sederhana dan lugas. 
                  4. Buat dalam maksimal 5 paragraf tanpa melibatkan formula matematika.
                
                Mulai jawaban dengan menuliskan kalimat: 
                Menurut blog ikanx101.com
                
                Akhiri jawaban dengan menuliskan sumber blog dari informasi yang diberikan
  ")

chat <- ellmer::chat_openai(
  prompt_,
  model = "gpt-4.1-mini",
  params = ellmer::params(temperature = .5)
)

# Register a retrieve tool with ellmer
ragnar_register_tool_retrieve(chat, store, top_k = 5)

live_browser(chat)

# untuk konek ke duckdb
# store <- ragnar::ragnar_store_connect("pairedends.ragnar.duckdb", read_only = TRUE)

