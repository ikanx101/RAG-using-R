# Read Me!


# Penjelasan

*Repository* ini berisi semua model dan *framework* LLM yang bisa
digunakan di departemen market riset Nutrifood.

# Setting Awal

Untuk bisa melakukan komputasi model **Huggingface** di *local computer*
menggunakan **R**, kita perlu membuat *virtual python environment*
dengan cara sebagai berikut:

## Tahap 1

Masuk ke `terminal` sebagai *super user*.

    sudo su

## Tahap 2

Pastikan *python* sudah ter-*install* lalu lakukan *update* sebagai
berikut:

    # kita update dan upgrade sistem linux nya
    apt update
    apt upgrade -y

    # kita akan install python3 environment terlebih dahulu
    apt install python3-venv
    python3 -m venv .env
    source .env/bin/activate

## Tahap 3

*Install library* `transformers` pada *local computer* sebagai berikut:

    # proses install transformers dan torch
    pip install transformers
    pip install 'transformers[torch]'
    pip install diffusers["torch"] transformers

Saya melakukan instalasi menggunakan perintah `pip`. Jadi pastikan `pip`
sudah ter-*install* terlebih dahulu.
