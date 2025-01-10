# Kode 4
rm(list=ls())
gc()

library(dplyr)
library(tidyr)
library(reticulate)

load("to qna.rda")

# Load Python libraries in R
transformers <- reticulate::import("transformers")
reader <- transformers$pipeline(task = "question-answering",
                                model="Rifky/Indobert-QA",
                                tokenizer="Rifky/Indobert-QA")

# Provide model with question and context
outputs <- reader(question = pertanyaan, context = dokumen)
outputs %>% as_tibble()


