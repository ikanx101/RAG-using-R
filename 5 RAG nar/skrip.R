rm(list=ls())
gc()

library(ragnar)
library(dplyr)
library(stringr)
library(ellmer)
library(rvest)
library(stringr)

Sys.setenv(OPENAI_API_KEY="")

base_url = "https://ikanx101.com"
pages    = ragnar_find_links(base_url)
pages    = pages[grepl("blog",pages)]

# Create and connect to a vector store
store_location <- "pairedends.ragnar.duckdb"
store <- ragnar_store_create(
  store_location,
  embed = \(x) ragnar::embed_openai(x, model = "text-embedding-3-small")
)

# Read each website and chunk it up
for (page in pages) {
  message("ingesting: ", page)
  chunks <- page |>
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

store_location <- "pairedends.ragnar.duckdb"
store <- ragnar_store_connect(store_location, read_only = TRUE)

text <- "bagaimana cara mengakses internet via CLI?"

relevant_chunks <- ragnar_retrieve_vss(
  store,
  text,
  top_k = 3
)
relevant_chunks$origin
relevant_chunks$context

# ambil teks
ambil_teks = function(url){
  baca  = url %>% read_html()
  laman = baca %>% html_nodes(".page__content p") %>% html_text()
  laman = gsub("\\\n","",laman)
  laman = stringr::str_squish(laman)
  laman = paste(laman,collapse = " ")
  laman = stringr::str_squish(laman)
  return(laman)
}

# alternatif 1
system_prompt <- stringr::str_squish(
  r"--(
  You are an expert of Data Science.
  You are concise. You always respond by first direct
  quoting material from data given, then adding
  your own additional context and interpertation.
  Always include links to the source materials used.
  )--"
)

chat <- ellmer::chat_deepseek(system_prompt)

# Register a retrieve tool with ellmer
ragnar_register_tool_retrieve(chat, store, top_k = 10)

# Run the query
chat$chat(text)

# alternatif 2
artikel = c()
for(i in 1:3){
  artikel = paste(artikel,
                  ambil_teks(relevant_chunks$origin[1]),
                  sep = "\n")
}

prompt = paste0("Berdasarkan informasi berikut ini: ",artikel,
                ". Jawablah pertanyaan ini: ",
                text,
                ". Dengan SYARAT berikut ini:",
                "ATURAN UTAMA: 
                  1. Dilarang menggunakan knowledge pada Deepsek.
                  2. Hanya gunakan informasi di atas. 
                  3. Tampilkan jawaban secara sederhana dan lugas. 
                  4. Buat dalam maksimal 3 paragraf tanpa melibatkan formula matematika.")

chat <- ellmer::chat_deepseek()
chat$chat(prompt)





# untuk konek ke duckdb
store <- ragnar::ragnar_store_connect("pairedends.ragnar.duckdb", read_only = TRUE)

