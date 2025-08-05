library(shiny)
library(tidyverse)
library(stringr)
library(ellmer)
library(rvest)
library(stringr)

rm(list=ls())

prompt_viz = 
  stringr::str_squish("Kamu adalah expert dalam bahasa R dengan spesialisasi di Tidyverse. 
                       Berikan jawaban berupa coding visualisasi menggunakan library(ggplot2) tanpa penjelasan.
                       Berikan warna yang cerah dengan nuansa biru. 
                       Hilangkan tulisan ``` pada kode yang dikeluarkan")
chat_viz = chat_deepseek(system_prompt = prompt_viz)

source("pembuat narasi.R")

ui <- fluidPage(
  titlePanel("Aplikasi Shiny dengan Eksekusi Kode Otomatis"),
  sidebarLayout(
    sidebarPanel(
      h4("CSV Automatic Viz"),
      fileInput("file1", "Choose a csv File"),
      tags$textarea(id = "input_code", 
                    rows = 10, cols = 40,
                    "Negara mana yang berpeluang menang dalam kompetisi?"),
      actionButton("run_btn", "Jalankan Kode")
    ),
    mainPanel(
      h4("Hasil Output:"),
      verbatimTextOutput("code_output"),
      plotOutput("plot_output")
    )
  )
)

server <- function(input, output, session) {
 
  # ini utk baca data
  data_upload <- reactive({
    inFile <- input$target_upload
    if (is.null(inFile))
      return(NULL)
    
    # baca data
    data <- read.csv(inFile$datapath) %>% janitor::clean_names() 
    
    info = generate_data_narrative(data)
    
    return(info)
  })
  
  info = data_upload
  
  tanya = reactive({
    paste0( "Saya bekerja dengan dataset dengan karakteristik berikut:\n",
            info,
            " buat skrip untuk ",
            input$input_code,
            "\n. Buat nama dataframe nya menjadi df dalam skrip.")
  })
    
  # Jalankan kode saat tombol ditekan
  observeEvent(input$run_btn, {
    code <- chat_viz$chat(tanya)
    
    tryCatch({
      output$code_output <- renderPrint({
        eval(parse(text = code))
      })
      
      output$plot_output <- renderPlot({
        eval(parse(text = code))
      })
    }, error = function(e) {
      output$code_output <- renderPrint({
        paste("Error:", e$message)
      })
    })
  })
}

shinyApp(ui = ui, server = server)