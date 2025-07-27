# Read Me!


## Penjelasan

*Folder* ini berisi algoritma untuk melakukan *clustering* dari suatu
kalimat dengan memanfaatkan LLM sebagai pembuat *ambedding matrix*.

Pada skrip `embedding.R`, saya hanya menuliskan algoritma sampai
pembuatan *embedding matrix* saja. Untuk melakukan *clustering*, kita
bisa melakukan cara sebagai berikut:

1.  *k-means clustering*. Caranya:
    - Pada *embedding matrix* yang ada, lakukan *dimension reduction*
      menggunakan `PCA` atau `t-SNE`.
    - Buat *k-means* dari **dua atau tiga** dimensi yang tereduksi.
2.  *Hierarchical clustering*. Caranya:
    - Langsung buat *dendogram* dari *embedding matrix*.
    - Tentukan berapa banyak *cluster* dari *dendogram* tersebut.

## Cara Pakai

Pastikan semua *libraries* ter-*install* dan *setting* awal pada
`read me` di *folder* awal sudah dilakukan.

Masukkan semua kalimat yang hendak dikelompokkan pada *file*
`komplen.txt`. Pisahkan dengan spasi ke bawah (`enter`).

*Run* skrip:

    source("embedding.R")
