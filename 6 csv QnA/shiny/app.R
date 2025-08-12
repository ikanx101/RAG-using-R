library(shiny)
library(tidyverse)
library(httr)
library(jsonlite)
library(glue)
library(DT)
library(ellmer)
library(ragnar)

rm(list=ls())

Sys.setenv(DEEPSEEK_API_KEY="sk-24d2a5762f0841d0abcf39e018034d69")

source("pembuat narasi.R")

prompt_viz = 
  stringr::str_squish("Kamu adalah expert dalam bahasa R dengan spesialisasi di Tidyverse. 
                       Berikan jawaban berupa coding visualisasi menggunakan library(ggplot2) atau library turunan ggplot2 lainnya tanpa penjelasan.
                       Berikan grafik dengan warna-warna yang cerah. 
                       Buat hanya 1 grafik saja sebagai output.
                       Hilangkan tulisan ```r dan ``` pada kode yang dikeluarkan")
chat_viz = chat_deepseek(system_prompt = prompt_viz)

# UI ----
ui <- fluidPage(
  titlePanel("ikanx101.com Visualization Generator"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV File", accept = ".csv"),
      textAreaInput("context", "Data Context", 
                    placeholder = "Jelaskan dan berikan konteks pada data Anda",
                    rows = 4),
      textAreaInput("question", "Mau tanya apa?", 
                    placeholder = "Mau tanya apa?",
                    rows = 4),
      actionButton("generate", "Buat visualisasinya!"),
      br(),
      h5("Created by ikanx101.com"),
      h6("Update: 12 Agustus 2025"),
      br(),
      textOutput("proses_kerja"),
      width = 4
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Preview", 
                 h3("Data Summary"),
                 verbatimTextOutput("narration"),
                 DTOutput("preview"),
                 br(),
                 h5("Saran analisa yang bisa dilakukan:")
                 verbatimTextOutput("saran_analisa")),
        tabPanel("Output Visualisasi dan Kode",
                 h3("Visualisasi"),
                 plotOutput("plot"),
                 h3("R Codes"),
                 verbatimTextOutput("code"))
      )
    )
  )
)

# Server ----
server <- function(input, output, session) {
  # Reactive untuk membaca data
  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # Output narasi
  output$narration <- renderPrint({
    req(data())
    generate_narration(data())
  })
  
  output$preview <- renderDT({
    datatable(head(data()), options = list(dom = 't'))
  })
  
  # Query ke Deepseek API
  query_deepseek <- function(narration, question,konteks) {
    prompt <- glue::glue(
      "Saya memiliki dataset dengan konteks {konteks} karakteristik berikut:\n\n{narration}\n\n",
      "Pertanyaan saya: {question}\n\n",
      "Bantu saya membuat visualisasi data di R menggunakan ggplot2 atau library turunan ggplot2 lainnya yang sesuai untuk menjawab pertanyaan ini. ",
      "Berikan hanya kode R lengkap yang bisa langsung dijalankan, tanpa penjelasan tambahan. ",
      "Gunakan data frame dengan nama 'df'. Pastikan kode termasuk semua library yang diperlukan.",
      "Hilangkan tulisan ```r dan ``` pada kode yang dikeluarkan"
    )
    
    chat_viz$chat(prompt)
  }
  
  # Query ke explain Deepseek API
  explain_deepseek <- function(code) {
    prompt <- glue::glue(
      "{code}\n\n",
      'Jelaskan proses kerja dari kode di atas.',
      'Jangan ada kode lagi dalam jawaban ini.',
      'Buat dalam bentuk cerita narasi singkat maksimal 2 paragraf.',
      'Jangan jelaskan tentang warna, judul, dan segala bentuk label.'
    )
    
    chat_viz$chat(prompt)
  }
  
  # Query minta saran Deepseek API
  saran_deepseek <- function(narration,konteks) {
    prompt <- glue::glue(
      "Saya memiliki dataset dengan konteks {konteks} karakteristik berikut:\n\n{narration}\n\n",
      "Kamu adalah analis data yang berpengalaman 10 tahun di bidang market riset, data analisis, dan data exploration.",
      "Berdasarkan dataset yang saya jelaskan, Berikan saya 5 saran analisa data yang bisa saya lakukan. Sajikan dalam poin-poin yang singkat dan padat.",
      "Jangan tambahkan knowledge di luar informasi yang saya berikan."
    )
    
    chat_viz$chat(prompt)
  }
  
  # Generate plot dan kode ketika tombol ditekan
  observeEvent(input$generate, {
    req(input$question, data())
    
    # Dapatkan narasi
    narration <- generate_narration(data())
    
    # Dapatkan kode dari API
    tryCatch({
      # generate code
      code <- query_deepseek(narration, input$question,input$context)
      # explain the code
      penjelasan = explain_deepseek(code)
      # kasih saran analisa
      analisa_saran = saran_deepseek(narration,input$context)
      
      # Simpan kode untuk ditampilkan
      output$code          = renderText(code)
      output$proses_kerja  = renderText(penjelasan)
      output$saran_analisa = renderText(analisa_saran)
      
      # Evaluasi kode untuk menghasilkan plot
      df <- data()  # Buat df tersedia untuk kode yang dihasilkan
      plot <- eval(parse(text = code))
      output$plot <- renderPlot(plot)
    }, error = function(e) {
      showNotification("Error generating visualization. Please try again.", type = "error")
    })
  })
  
  
  
  
  
}

# Run app ----
shinyApp(ui, server)