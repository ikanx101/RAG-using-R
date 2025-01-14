rm(list=ls())
gc()

# Load necessary libraries
library(reticulate)
library(dplyr)

# memanggil model dari huggingface
transformers = reticulate::import("transformers")
pipe         = transformers$pipeline(
  "text-classification",
  model = "ayameRushia/roberta-base-indonesian-1.5G-sentiment-analysis-smsa"
)


# kita bikin function utk mengambil datanya
sentimen_donk = function(){
  input  = readline(prompt = "Masukkan kalimat yang hendak dicek sentimennya:\n")
  result = pipe(input)
  output = 
    data.frame(kalimat  = input,
               sentimen = result[[1]]$label,
               skor     = result[[1]]$score)
  
  print(output)
}

# sentimen_donk()

# ini sebagai set awal
ulang = T
# kita bikin loop dulu deh ya
while(ulang){
  sentimen_donk()
  ulang_gak = readline(prompt = "Input lagi? (Y/N) ")
  ulang     = ifelse(ulang_gak == "Y",T,F)
  cat("\014")
}
