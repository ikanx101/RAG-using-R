library(shiny)

ui <- fluidPage(
  titlePanel("Aplikasi Shiny dengan Eksekusi Kode Otomatis"),
  sidebarLayout(
    sidebarPanel(
      h4("Kode R yang akan dijalankan:"),
      tags$textarea(id = "input_code", 
                    rows = 10, cols = 40,
                    "summary(mtcars)\nplot(mtcars$mpg, mtcars$hp)"),
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
  # Jalankan kode secara otomatis saat aplikasi dimuat
  observe({
    # Jalankan kode default saat pertama kali dimuat
    code <- isolate(input$input_code)
    
    tryCatch({
      # Jalankan kode dan tangkap output teks
      output$code_output <- renderPrint({
        eval(parse(text = code))
      })
      
      # Tangkap plot jika ada
      output$plot_output <- renderPlot({
        eval(parse(text = code))
      })
    }, error = function(e) {
      output$code_output <- renderPrint({
        paste("Error:", e$message)
      })
    })
  })
  
  # Jalankan kode saat tombol ditekan
  observeEvent(input$run_btn, {
    code <- input$input_code
    
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