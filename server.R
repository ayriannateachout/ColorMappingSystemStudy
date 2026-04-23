library(shiny)

# =========================
# CORE COLOR MAPPING
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
  
  grDevices::hcl(h = h, c = C, l = L)
}

# =========================
# FEELINGS WHEEL
# =========================
FEELINGS_WHEEL <- data.frame(
  emotion = c("Joy", "Trust", "Anticipation", "Surprise", "Fear", "Sadness", "Disgust", "Anger"),
  h_center = c(50, 100, 30, 300, 210, 240, 140, 0),
  stringsAsFactors = FALSE
)

circular_distance <- function(a, b) {
  diff <- abs(a - b) %% 360
  min(diff, 360 - diff)
}

get_feelings_label <- function(hue) {
  dists <- sapply(FEELINGS_WHEEL$h_center, function(center) {
    circular_distance(hue, center)
  })
  
  idx <- which.min(dists)
  min_dist <- dists[idx]
  
  list(
    emotion = FEELINGS_WHEEL$emotion[idx],
    confidence = round(1 - (min_dist / 180), 3),
    center = FEELINGS_WHEEL$h_center[idx]
  )
}

snap_hue_to_wheel <- function(hue, enabled) {
  if (!enabled) return(hue)
  info <- get_feelings_label(hue)
  info$center
}

# =========================
# SERVER
# =========================
function(input, output, session) {
  
  # -------------------------
  # LCh + Color
  # -------------------------
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
  
  current_hex <- reactive({
    lch_to_hex(current_lch()$L, current_lch()$C, final_hue())
  })
  
  output$lch_output <- renderPrint({
    req(current_lch())
    
    print(list(
      Lightness = round(current_lch()$L, 2),
      Chroma = round(current_lch()$C, 2),
      Hue = round(final_hue(), 2)
    ))
  })
  
  output$unique_hue_output <- renderPrint({
    req(current_lch())
    
    cat(
      "Unique Hue Interpretation:", "\n",
      "The current modeled hue is", round(final_hue(), 2), "degrees.", "\n",
      "This represents the continuous angular color position produced by the current valence and arousal values.",
      sep = " "
    )
  })
  
  output$hex_output <- renderPrint({
    req(current_hex())
    print(list(Hex = current_hex()))
  })
  
  output$color_swatch <- renderUI({
    req(current_hex())
    
    tags$div(
      style = paste0(
        "width:100%; height:140px;",
        "background-color:", current_hex(), ";",
        "border-radius:12px; border:2px solid #444;"
      )
    )
  })
  
  # -------------------------
  # PLUTCHIK LABEL
  # -------------------------
  output$wheel_info <- renderPrint({
    req(current_lch())
    
    base_h <- current_lch()$h
    
    if (isTRUE(input$use_wheel)) {
      info <- get_feelings_label(base_h)
      
      print(list(
        "Nearest Plutchik Label" = info$emotion,
        "Confidence" = info$confidence,
        "Base Hue" = round(base_h, 2),
        "Final Hue" = round(final_hue(), 2)
      ))
    } else {
      print(list(
        "Continuous Hue Only" = round(base_h, 2)
      ))
    }
  })
  
  # -------------------------
  # MODEL LOGIC
  # -------------------------
  current_model_values <- reactive({
    v <- input$valence_test
    a <- input$arousal_test
    
    constriction <- abs(v) * abs(a)
    defusion <- (1 - abs(v)) * (1 - abs(a))
    z <- constriction - defusion
    r <- sqrt(v^2 + a^2)
    
    theta_rad <- atan2(a, v)
    theta_deg <- (theta_rad * 180 / pi) %% 360
    
    list(
      valence = v,
      arousal = a,
      constriction = constriction,
      defusion = defusion,
      z = z,
      r = r,
      theta_deg = theta_deg
    )
  })
  
  output$model_inputs_output <- renderPrint({
    vals <- current_model_values()
    
    print(list(
      Valence = round(vals$valence, 3),
      Arousal = round(vals$arousal, 3)
    ))
  })
  
  output$model_structure_output <- renderPrint({
    vals <- current_model_values()
    
    print(list(
      "Angular Direction (degrees)" = round(vals$theta_deg, 2),
      "Constriction" = round(vals$constriction, 3),
      "Defusion" = round(vals$defusion, 3),
      "Structural Axis z" = round(vals$z, 3),
      "Magnitude r" = round(vals$r, 3)
    ))
  })
  
  output$state_snapshot_table <- renderTable({
    vals <- current_model_values()
    
    data.frame(
      Measure = c(
        "Valence",
        "Arousal",
        "Direction (degrees)",
        "Constriction",
        "Defusion",
        "Structural Axis z",
        "Magnitude r",
        "Hue",
        "Hex"
      ),
      Value = c(
        round(vals$valence, 3),
        round(vals$arousal, 3),
        round(vals$theta_deg, 2),
        round(vals$constriction, 3),
        round(vals$defusion, 3),
        round(vals$z, 3),
        round(vals$r, 3),
        round(final_hue(), 2),
        current_hex()
      ),
      check.names = FALSE
    )
  }, striped = TRUE, bordered = TRUE, spacing = "m")
  
  output$prototype_interpretation <- renderPrint({
    vals <- current_model_values()
    
    structure_text <- if (vals$z > 0.15) {
      "The current state leans more constricted than diffuse."
    } else if (vals$z < -0.15) {
      "The current state leans more diffuse than constricted."
    } else {
      "The current state appears relatively balanced between constriction and diffusion."
    }
    
    intensity_text <- if (vals$r > 0.8) {
      "The overall magnitude is relatively strong."
    } else if (vals$r > 0.4) {
      "The overall magnitude is moderate."
    } else {
      "The overall magnitude is relatively gentle."
    }
    
    direction_text <- if (vals$valence >= 0.5 && vals$arousal >= 0.5) {
      "The point occupies a higher-valence, higher-arousal region."
    } else if (vals$valence < 0.5 && vals$arousal >= 0.5) {
      "The point occupies a lower-valence, higher-arousal region."
    } else if (vals$valence < 0.5 && vals$arousal < 0.5) {
      "The point occupies a lower-valence, lower-arousal region."
    } else {
      "The point occupies a higher-valence, lower-arousal region."
    }
    
    cat(
      structure_text, "\n\n",
      intensity_text, "\n\n",
      direction_text, "\n\n",
      "The current hue and color output provide a continuous perceptual expression of this position.",
      sep = ""
    )
  })
  
  # -------------------------
  # PLOT
  # -------------------------
  output$emotion_map_plot <- renderPlot({
    vals <- current_model_values()
    
    plot(
      x = vals$valence,
      y = vals$arousal,
      xlim = c(0, 1),
      ylim = c(0, 1),
      xlab = "Valence",
      ylab = "Arousal",
      main = "2D Emotional Position",
      pch = 19,
      cex = 2,
      col = current_hex()
    )
    
    abline(h = seq(0, 1, by = 0.25), col = "gray85", lty = 3)
    abline(v = seq(0, 1, by = 0.25), col = "gray85", lty = 3)
    
    text(0.15, 0.92, "low valence\nhigh arousal", cex = 0.8, col = "gray40")
    text(0.85, 0.92, "high valence\nhigh arousal", cex = 0.8, col = "gray40")
    text(0.15, 0.08, "low valence\nlow arousal", cex = 0.8, col = "gray40")
    text(0.85, 0.08, "high valence\nlow arousal", cex = 0.8, col = "gray40")
    
    points(vals$valence, vals$arousal, pch = 19, cex = 2.4, col = current_hex())
  })
  
  # -------------------------
  # PHASE 7 PART 1 - DATA IMPLEMENTATION
  # -------------------------
  
  data_file <- "data/emotion_data.csv"
  
  data_loaded <- reactive({
    if (file.exists(data_file)) {
      read.csv(data_file)
    } else {
      NULL
    }
  })
  
  output$data_status <- renderPrint({
    if (is.null(data_loaded())) {
      cat("No dataset found. Please place a CSV file in the data folder named 'emotion_data.csv'.")
    } else {
      cat("Dataset loaded successfully.")
    }
  })
  
  output$data_preview <- renderTable({
    req(data_loaded())
    head(data_loaded(), 10)
  })
  
  # apply model to dataset
  model_applied_data <- reactive({
    df <- data_loaded()
    req(df)
    
    # expect columns: valence, arousal
    df$constriction <- abs(df$valence) * abs(df$arousal)
    df$defusion <- (1 - abs(df$valence)) * (1 - abs(df$arousal))
    df$z <- df$constriction - df$defusion
    df$r <- sqrt(df$valence^2 + df$arousal^2)
    df$theta <- (atan2(df$arousal, df$valence) * 180 / pi) %% 360
    
    df
  })
  
  output$model_applied_table <- renderTable({
    req(model_applied_data())
    head(model_applied_data(), 10)
  })
  
  output$data_summary_output <- renderPrint({
    df <- model_applied_data()
    req(df)
    
    cat("Number of observations:", nrow(df), "\n\n")
    
    cat("Average Valence:", round(mean(df$valence, na.rm = TRUE), 3), "\n")
    cat("Average Arousal:", round(mean(df$arousal, na.rm = TRUE), 3), "\n\n")
    
    cat("Average Structural Axis (z):", round(mean(df$z, na.rm = TRUE), 3), "\n")
    cat("Average Magnitude (r):", round(mean(df$r, na.rm = TRUE), 3), "\n")
  })
  # -------------------------
  # FORMULA PAGE OUTPUTS
  # -------------------------
  output$formula1 <- renderText({
    paste(
      "constriction = |valence| × |arousal|",
      "defusion = (1 − |valence|)(1 − |arousal|)",
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