# Read Me!


## Penjelasan Umum

*Folder* ini berisi *script* bernama `sentimen.R` yang berisi algoritma
untuk melakukan penilaian sentimen dari suatu kalimat.

Cara kerjanya adalah sebagai berikut:

    STEP 1
      clean environment
      panggil libraries dan python
      
    STEP 2
      ambil model LLM sentimen bahasa indonesia dari huggingface
      
    STEP 3
      input: 
        kalimat yang hendak diuji
      output:
        sentimen dan skornya

## Cara Menggunakan

Lakukan persiapan dengan *install* semua bumbu yang diperlukan (*refer
to* artikel `Read Me` pada *folder* sebelumnya).

*Run* skrip berikut ini pada **R**:

    source("sentimen.R")

Untuk mengubah model LLM yang digunakan, silakan ubah nama model di
Huggingface pada **baris 12** di `sentimen.R`.
