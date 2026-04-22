library(shiny)

# =========================
# CORE COLOR MAPPING (RESEARCH ARTIFACT)
# =========================
affect_to_lch <- function(valence, arousal) {
  v <- min(max(valence, 0), 1)
  a <- min(max(arousal, 0), 1)
  
  h <- 240 * (1 - v)
  C <- 20 + (60 * a)
  L <- 60 + (20 * a)
  
  list(L = L, C = C, h = h)
}

# =========================
# LCh -> HEX
# =========================
lch_to_hex <- function(L, C, h) {
  L <- min(max(as.numeric(L), 0), 100)
  C <- max(as.numeric(C), 0)
  h <- as.numeric(h) %% 360
  
  h_rad <- h * pi / 180
  a_lab <- C * cos(h_rad)
  b_lab <- C * sin(h_rad)
  
  lab_matrix <- matrix(c(L, a_lab, b_lab), ncol = 3)
  
  rgb <- grDevices::convertColor(
    lab_matrix,
    from = "Lab",
    to = "sRGB",
    scale.in = 100,
    scale.out = 1,
    clip = TRUE
  )
  
  rgb <- pmin(pmax(rgb, 0), 1)
  
  grDevices::rgb(rgb[1, 1], rgb[1, 2], rgb[1, 3])
}

# =========================
# FEELINGS WHEEL
# =========================
FEELINGS_WHEEL <- data.frame(
  emotion = c("Joy", "Trust", "Anticipation", "Surprise", "Fear", "Sadness", "Disgust", "Anger"),
  h_center = c(50, 100, 30, 300, 210, 240, 140, 0),
  width = c(40, 40, 40, 50, 50, 50, 50, 50),
  stringsAsFactors = FALSE
)

circular_distance <- function(a, b) {
  diff <- abs(a - b) %% 360
  min(diff, 360 - diff)
}

get_feelings_label <- function(hue) {
  dists <- sapply(FEELINGS_WHEEL$h_center, function(center) circular_distance(hue, center))
  idx <- which.min(dists)
  
  min_dist <- dists[idx]
  confidence <- max(0, 1 - (min_dist / 180))
  
  list(
    emotion = FEELINGS_WHEEL$emotion[idx],
    confidence = round(confidence, 3),
    center = FEELINGS_WHEEL$h_center[idx]
  )
}

snap_hue_to_wheel <- function(hue, enabled) {
  if (!enabled) return(hue)
  info <- get_feelings_label(hue)
  info$center
}

# =========================
# NORMALIZATION
# =========================
extract_time_series <- function(df) {
  df[, -1, drop = FALSE]
}

compute_min_max <- function(valence_df, arousal_df) {
  v_ts <- extract_time_series(valence_df)
  a_ts <- extract_time_series(arousal_df)
  
  list(
    v_min = as.numeric(min(as.matrix(v_ts), na.rm = TRUE)),
    v_max = as.numeric(max(as.matrix(v_ts), na.rm = TRUE)),
    a_min = as.numeric(min(as.matrix(a_ts), na.rm = TRUE)),
    a_max = as.numeric(max(as.matrix(a_ts), na.rm = TRUE))
  )
}

normalize_time_series <- function(df, min_val, max_val) {
  ts <- extract_time_series(df)
  denom <- if ((max_val - min_val) != 0) (max_val - min_val) else 1
  
  norm <- (ts - min_val) / denom
  norm[norm < 0] <- 0
  norm[norm > 1] <- 1
  norm
}

get_normalized_affect_timeseries <- function(valence_df, arousal_df) {
  stats <- compute_min_max(valence_df, arousal_df)
  
  v_norm <- normalize_time_series(valence_df, stats$v_min, stats$v_max)
  a_norm <- normalize_time_series(arousal_df, stats$a_min, stats$a_max)
  
  list(v_norm = v_norm, a_norm = a_norm, stats = stats)
}

# =========================
# SERVER
# =========================
function(input, output, session) {
  
  data_path <- "data"
  arousal_file <- file.path(data_path, "arousal.csv")
  valence_file <- file.path(data_path, "valence.csv")
  
  file_exists <- reactive({
    file.exists(arousal_file) && file.exists(valence_file)
  })
  
  output$file_status <- renderPrint({
    if (!file_exists()) {
      cat("CSV files not found.\n")
    } else {
      cat("CSV files found successfully.\n")
    }
  })
  
  raw_data <- reactive({
    req(file_exists())
    
    arousal_df <- read.csv(arousal_file, check.names = FALSE)
    valence_df <- read.csv(valence_file, check.names = FALSE)
    
    list(arousal_df = arousal_df, valence_df = valence_df)
  })
  
  normalized_data <- reactive({
    req(raw_data())
    
    get_normalized_affect_timeseries(
      raw_data()$valence_df,
      raw_data()$arousal_df
    )
  })
  
  output$norm_stats <- renderPrint({
    req(file_exists())
    print(normalized_data()$stats)
  })
  
  current_lch <- reactive({
    affect_to_lch(input$valence_test, input$arousal_test)
  })
  
  final_hue <- reactive({
    base_h <- current_lch()$h
    
    if (isTRUE(input$use_wheel)) {
      snap_hue_to_wheel(base_h, isTRUE(input$snap_to_emotion))
    } else {
      base_h
    }
  })
  
  output$lch_output <- renderPrint({
    req(current_lch())
    
    print(list(
      L = round(current_lch()$L, 2),
      C = round(current_lch()$C, 2),
      h = round(final_hue(), 2)
    ))
  })
  
  current_hex <- reactive({
    lch_to_hex(current_lch()$L, current_lch()$C, final_hue())
  })
  
  output$hex_output <- renderPrint({
    req(current_hex())
    print(current_hex())
  })
  
  output$color_swatch <- renderUI({
    req(current_hex())
    
    tags$div(
      style = paste0(
        "width:100%; height:140px; background-color:", current_hex(), ";",
        "border-radius:12px;"
      )
    )
  })
  
  # =========================
  # FORMULA PAGE OUTPUTS (NEW)
  # =========================
  
  output$formula1 <- renderText({
    paste(
      "constriction = |valence| × |arousal|",
      "defusion = (1 − |valence|) × (1 − |arousal|)",
      sep = "\n"
    )
  })
  
  output$formula2 <- renderText({
    "z = constriction − defusion"
  })
  
  output$formula3 <- renderText({
    paste(
      "θ = atan2(arousal, valence)",
      "z = constriction − defusion",
      "r = √(valence² + arousal²)",
      sep = "\n"
    )
  })
  
}