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
        "width:100%; height:140px;",
        "background-color:", current_hex(), ";",
        "border-radius:12px;"
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
        Emotion = info$emotion,
        Confidence = info$confidence,
        Base_Hue = round(base_h, 2),
        Final_Hue = round(final_hue(), 2)
      ))
    } else {
      print(list(Hue = round(base_h, 2)))
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
      Direction = round(vals$theta_deg, 2),
      Constriction = round(vals$constriction, 3),
      Defusion = round(vals$defusion, 3),
      Z = round(vals$z, 3),
      Magnitude = round(vals$r, 3)
    ))
  })
  
  output$prototype_interpretation <- renderPrint({
    vals <- current_model_values()
    
    structure_text <- if (vals$z > 0.15) {
      "more constricted than diffuse"
    } else if (vals$z < -0.15) {
      "more diffuse than constricted"
    } else {
      "balanced between constriction and diffusion"
    }
    
    intensity_text <- if (vals$r > 0.8) {
      "strong intensity"
    } else if (vals$r > 0.4) {
      "moderate intensity"
    } else {
      "gentle intensity"
    }
    
    cat(
      "This state appears", structure_text, "with", intensity_text, "."
    )
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