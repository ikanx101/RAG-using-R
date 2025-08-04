generate_data_narrative <- function(file_path) {
  # Membaca data
  data <- read_csv(file_path, show_col_types = FALSE)
  
  # Menghitung statistik dasar
  total_rows <- nrow(data)
  total_cols <- ncol(data)
  missing_values <- sum(is.na(data))
  
  # Mendapatkan informasi tipe data
  col_types <- map_chr(data, ~class(.x)[1])
  col_types_summary <- table(col_types) %>% 
    as.data.frame() %>% 
    mutate(Description = case_when(
      col_types == "numeric" ~ "numerik (angka)",
      col_types == "integer" ~ "numerik (bilangan bulat)",
      col_types == "character" ~ "teks/kategorikal",
      col_types == "factor" ~ "kategorikal",
      col_types == "logical" ~ "logika (TRUE/FALSE)",
      col_types == "Date" ~ "tanggal",
      TRUE ~ col_types
    ))
  
  # Membuat narasi
  narrative <- c(
    paste0("Dataset ini terdiri dari ", total_rows, " baris (observasi) dan ", 
           total_cols, " kolom (variabel)."),
    paste0("Secara keseluruhan terdapat ", missing_values, " nilai yang hilang (NA) dalam dataset."),
    "\nTipe Data Kolom:",
    capture.output(print(col_types_summary, row.names = FALSE)),
    "\nDetail Kolom:"
  )
  
  # Menambahkan deskripsi per kolom
  for (col in names(data)) {
    col_data <- data[[col]]
    col_type <- class(col_data)[1]
    na_count <- sum(is.na(col_data))
    unique_count <- n_distinct(col_data, na.rm = TRUE)
    
    col_stats <- if (is.numeric(col_data)) {
      paste0(
        "Rentang: ", round(min(col_data, na.rm = TRUE), 2), " - ", 
        round(max(col_data, na.rm = TRUE), 2),
        ", Rata-rata: ", round(mean(col_data, na.rm = TRUE), 2),
        ", Median: ", round(median(col_data, na.rm = TRUE), 2)
      )
    } else if (is.character(col_data) || is.factor(col_data)) {
      top_values <- table(col_data) %>% 
        sort(decreasing = TRUE) %>% 
        head(3) %>% 
        names() %>% 
        paste(collapse = ", ")
      paste0("Nilai unik: ", unique_count, ", Nilai paling umum: ", top_values)} 
    else if (is.logical(col_data)) {
      paste0("Proporsi TRUE: ", round(mean(col_data, na.rm = TRUE) * 100, "%"))} 
    else {
      ""
    }
    
    narrative <- c(
      narrative,
      paste0(
        "- ", col, " (", col_type, "): ", 
        na_count, " NA, ", unique_count, " nilai unik. ",
        col_stats
      )
    )
  }
  
  # Menambahkan contoh data
  narrative <- c(
    narrative,
    "\nContoh Data:",
    capture.output(print(head(data), n = 3))
  )
  
  return(paste(narrative, collapse = "\n"))
}