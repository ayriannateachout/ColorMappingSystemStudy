library(shiny)

# =========================
# CORE COLOR MAPPING
# =========================
affect_to_lch <- function(valence, arousal) {
  v <- min(max(valence, -1), 1)
  a <- min(max(arousal, 0), 1)
  
  v_scaled <- (v + 1) / 2
  h <- 240 * (1 - v_scaled)
  
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
  
  grDevices::hcl(h = h, c = C, l = L, fixup = TRUE)
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
# SPHERE MAPPING HELPERS
# =========================
map_z_to_lightness <- function(z) {
  z_clamped <- pmax(pmin(z, 1), -1)
  65 + (20 * z_clamped)
}

map_r_to_chroma <- function(r) {
  r_clamped <- pmax(pmin(r, 1.5), 0)
  20 + (40 * (r_clamped / 1.5))
}

# =========================
# SONG SUMMARY HELPERS
# =========================
circular_mean_degrees <- function(theta_deg) {
  theta_rad <- theta_deg * pi / 180
  mean_x <- mean(cos(theta_rad), na.rm = TRUE)
  mean_y <- mean(sin(theta_rad), na.rm = TRUE)
  ((atan2(mean_y, mean_x) * 180 / pi) %% 360)
}

top_plutchik_labels <- function(theta_values, top_n = 3) {
  labels <- sapply(theta_values, function(th) {
    get_feelings_label(th)$emotion
  })
  
  counts <- sort(table(labels), decreasing = TRUE)
  top_labels <- names(counts)[seq_len(min(top_n, length(counts)))]
  paste(top_labels, collapse = ", ")
}

interpret_song_summary <- function(mean_z, mean_r, mean_theta) {
  structure_text <- if (mean_z > 0.10) {
    "leans toward constriction"
  } else if (mean_z < -0.10) {
    "leans toward defusion"
  } else {
    "remains relatively balanced"
  }
  
  intensity_text <- if (mean_r > 0.80) {
    "with stronger overall intensity"
  } else if (mean_r > 0.40) {
    "with moderate overall intensity"
  } else {
    "with gentler overall intensity"
  }
  
  paste(
    "This song", structure_text, intensity_text,
    "and centers around", round(mean_theta, 1), "degrees on the emotional equator."
  )
}

# =========================
# SERVER
# =========================
function(input, output, session) {
  
  # -------------------------
  # PROTOTYPE PAGE
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
      "This represents the continuous angular position generated from the current valence and arousal inputs and serves as an entry point into the emotional equator used in the broader sphere model.",
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
  
  output$prototype_interpretation <- renderPrint({
    vals <- current_model_values()
    
    structure_text <- if (vals$z > 0.15) {
      "The current state leans more toward constriction than defusion."
    } else if (vals$z < -0.15) {
      "The current state leans more toward defusion than constriction."
    } else {
      "The current state appears relatively balanced between constriction and defusion."
    }
    
    intensity_text <- if (vals$r > 1.0) {
      "Its overall magnitude is relatively strong."
    } else if (vals$r > 0.5) {
      "Its overall magnitude is moderate."
    } else {
      "Its overall magnitude is relatively gentle."
    }
    
    direction_text <- if (vals$valence > 0.2) {
      "Its angular direction is currently pulled toward a more positive side of the emotional circle."
    } else if (vals$valence < -0.2) {
      "Its angular direction is currently pulled toward a more negative side of the emotional circle."
    } else {
      "Its angular direction currently remains near the middle of the valence axis."
    }
    
    activation_text <- if (vals$arousal > 0.7) {
      "The activation level is relatively elevated."
    } else if (vals$arousal > 0.3) {
      "The activation level is moderate."
    } else {
      "The activation level is relatively low."
    }
    
    cat(
      structure_text, "\n\n",
      intensity_text, "\n\n",
      direction_text, "\n\n",
      activation_text, "\n\n",
      "Together, these inputs generate a continuous hue and color output that can later be placed into the broader sphere model.",
      sep = ""
    )
  })
  
  output$emotion_map_plot <- renderPlot({
    vals <- current_model_values()
    
    plot(
      x = vals$valence,
      y = vals$arousal,
      xlim = c(-1, 1),
      ylim = c(0, 1),
      xlab = "Valence",
      ylab = "Arousal",
      main = "2D Input View",
      pch = 19,
      cex = 2,
      col = current_hex()
    )
    
    abline(h = seq(0, 1, by = 0.25), col = "gray85", lty = 3)
    abline(v = seq(-1, 1, by = 0.5), col = "gray85", lty = 3)
    
    text(-0.75, 0.92, "negative\nhigher arousal", cex = 0.8, col = "gray40")
    text(0.75, 0.92, "positive\nhigher arousal", cex = 0.8, col = "gray40")
    text(-0.75, 0.08, "negative\nlower arousal", cex = 0.8, col = "gray40")
    text(0.75, 0.08, "positive\nlower arousal", cex = 0.8, col = "gray40")
    
    points(vals$valence, vals$arousal, pch = 19, cex = 2.4, col = current_hex())
  })
  
  # -------------------------
  # DATA IMPLEMENTATION WITH DEAM
  # -------------------------
  valence_file <- "data/valence.csv"
  arousal_file <- "data/arousal.csv"
  
  deam_loaded <- reactive({
    if (!file.exists(valence_file) || !file.exists(arousal_file)) {
      return(NULL)
    }
    
    valence_df <- read.csv(valence_file, check.names = FALSE)
    arousal_df <- read.csv(arousal_file, check.names = FALSE)
    
    list(valence = valence_df, arousal = arousal_df)
  })
  
  output$data_status <- renderPrint({
    if (is.null(deam_loaded())) {
      cat("DEAM files not found. Please place valence.csv and arousal.csv in the data folder.")
    } else {
      cat("DEAM valence and arousal files loaded successfully.")
    }
  })
  
  output$song_selector <- renderUI({
    req(deam_loaded())
    
    song_ids <- intersect(deam_loaded()$valence$song_id, deam_loaded()$arousal$song_id)
    song_ids <- sort(song_ids)
    
    selectInput("selected_song_id", "Choose a song ID", choices = song_ids, selected = song_ids[1])
  })
  
  get_song_time_series <- function(song_id, deam_data) {
    valence_df <- deam_data$valence
    arousal_df <- deam_data$arousal
    
    v_row <- valence_df[valence_df$song_id == song_id, , drop = FALSE]
    a_row <- arousal_df[arousal_df$song_id == song_id, , drop = FALSE]
    
    if (nrow(v_row) == 0 || nrow(a_row) == 0) return(NULL)
    
    sample_cols_v <- names(v_row)[grepl("^sample_", names(v_row))]
    sample_cols_a <- names(a_row)[grepl("^sample_", names(a_row))]
    common_samples <- intersect(sample_cols_v, sample_cols_a)
    
    if (length(common_samples) == 0) return(NULL)
    
    time_vals <- as.numeric(gsub("sample_|ms", "", common_samples))
    ordered_idx <- order(time_vals)
    
    common_samples <- common_samples[ordered_idx]
    time_vals <- time_vals[ordered_idx]
    
    valence_vals <- as.numeric(v_row[1, common_samples, drop = TRUE])
    arousal_vals <- as.numeric(a_row[1, common_samples, drop = TRUE])
    
    df <- data.frame(
      time = time_vals,
      valence = valence_vals,
      arousal = arousal_vals
    )
    
    df <- df[is.finite(df$time) & is.finite(df$valence) & is.finite(df$arousal), , drop = FALSE]
    if (nrow(df) == 0) return(NULL)
    
    df$constriction <- abs(df$valence) * abs(df$arousal)
    df$defusion <- (1 - abs(df$valence)) * (1 - abs(df$arousal))
    df$z <- df$constriction - df$defusion
    df$r <- sqrt(df$valence^2 + df$arousal^2)
    df$theta <- (atan2(df$arousal, df$valence) * 180 / pi) %% 360
    
    df
  }
  
  current_song_data <- reactive({
    req(deam_loaded(), input$selected_song_id)
    get_song_time_series(as.numeric(input$selected_song_id), deam_loaded())
  })
  
  output$song_data_preview <- renderTable({
    req(current_song_data())
    head(current_song_data(), 10)
  }, striped = TRUE, bordered = TRUE, spacing = "m")
  
  output$model_applied_table <- renderTable({
    req(current_song_data())
    
    out <- current_song_data()[, c("time", "valence", "arousal", "constriction", "defusion", "z", "r", "theta")]
    head(out, 12)
  }, striped = TRUE, bordered = TRUE, spacing = "m")
  
  output$valence_arousal_plot <- renderPlot({
    req(current_song_data())
    df <- current_song_data()
    
    plot(
      df$time, df$valence,
      type = "l",
      lwd = 2,
      col = "blue",
      ylim = range(c(df$valence, df$arousal), na.rm = TRUE),
      xlab = "Time (ms)",
      ylab = "Value",
      main = paste("Valence and Arousal Over Time — Song", input$selected_song_id)
    )
    lines(df$time, df$arousal, lwd = 2, col = "red")
    legend("topright", legend = c("Valence", "Arousal"), col = c("blue", "red"), lty = 1, lwd = 2, bty = "n")
  })
  
  output$structure_plot <- renderPlot({
    req(current_song_data())
    df <- current_song_data()
    
    plot(
      df$time, df$z,
      type = "l",
      lwd = 2,
      col = "darkgreen",
      xlab = "Time (ms)",
      ylab = "Structural Axis z",
      main = paste("Constriction vs Defusion Across Time — Song", input$selected_song_id)
    )
    abline(h = 0, lty = 2, col = "gray40")
  })
  
  # -------------------------
  # SPHERE COORDINATES + COLOR MAPPING
  # -------------------------
  current_song_sphere <- reactive({
    req(current_song_data())
    df <- current_song_data()
    
    df$hue <- df$theta
    df$lightness <- map_z_to_lightness(df$z)
    df$chroma <- map_r_to_chroma(df$r)
    
    df$hex <- mapply(
      FUN = function(L, C, h) {
        lch_to_hex(L, C, h)
      },
      df$lightness,
      df$chroma,
      df$hue
    )
    
    df
  })
  
  output$sphere_table <- renderTable({
    req(current_song_sphere())
    
    out <- current_song_sphere()[, c(
      "time", "theta", "z", "r", "hue", "lightness", "chroma", "hex"
    )]
    
    head(out, 12)
  }, striped = TRUE, bordered = TRUE, spacing = "m")
  
  output$sphere_coordinate_plot <- renderPlot({
    req(current_song_sphere())
    df <- current_song_sphere()
    
    plot(
      df$theta,
      df$z,
      pch = 19,
      cex = 1.4,
      col = df$hex,
      xlim = c(0, 360),
      ylim = c(-1, 1),
      xlab = "Equator Angle / Plutchik Direction (degrees)",
      ylab = "Vertical Structure (Constriction ↔ Defusion)",
      main = paste("2D Sphere Coordinate View — Song", input$selected_song_id)
    )
    
    abline(h = 0, lty = 2, col = "gray40")
    abline(v = seq(0, 360, by = 45), lty = 3, col = "gray85")
    
    text(180, 0.92, "Constriction", cex = 0.9, col = "gray30")
    text(180, -0.92, "Defusion", cex = 0.9, col = "gray30")
  })
  
  output$sphere_interpretation <- renderPrint({
    req(current_song_sphere())
    df <- current_song_sphere()
    
    mean_z <- mean(df$z, na.rm = TRUE)
    mean_r <- mean(df$r, na.rm = TRUE)
    mean_theta <- circular_mean_degrees(df$theta)
    
    structure_text <- if (mean_z > 0.1) {
      "This song leans more toward constriction than defusion across time."
    } else if (mean_z < -0.1) {
      "This song leans more toward defusion than constriction across time."
    } else {
      "This song remains relatively balanced between constriction and defusion across time."
    }
    
    intensity_text <- if (mean_r > 0.8) {
      "Its average emotional magnitude is relatively strong."
    } else if (mean_r > 0.4) {
      "Its average emotional magnitude is moderate."
    } else {
      "Its average emotional magnitude is relatively gentle."
    }
    
    direction_text <- paste(
      "Its average angular direction is",
      round(mean_theta, 2),
      "degrees, placing it along the emotional equator rather than inside a fixed single category."
    )
    
    cat(
      structure_text, "\n\n",
      intensity_text, "\n\n",
      direction_text, "\n\n",
      "Darker mapped values correspond to upward movement toward constriction, while lighter mapped values correspond to downward movement toward defusion.",
      sep = ""
    )
  })
  
  output$data_summary_output <- renderPrint({
    req(current_song_sphere())
    df <- current_song_sphere()
    
    cat("Song ID:", input$selected_song_id, "\n\n")
    cat("Observations:", nrow(df), "\n")
    cat("Mean Valence:", round(mean(df$valence, na.rm = TRUE), 3), "\n")
    cat("Mean Arousal:", round(mean(df$arousal, na.rm = TRUE), 3), "\n")
    cat("Mean Constriction:", round(mean(df$constriction, na.rm = TRUE), 3), "\n")
    cat("Mean Defusion:", round(mean(df$defusion, na.rm = TRUE), 3), "\n")
    cat("Mean Structural Axis z:", round(mean(df$z, na.rm = TRUE), 3), "\n")
    cat("Mean Magnitude r:", round(mean(df$r, na.rm = TRUE), 3), "\n")
    cat("Mean Hue:", round(circular_mean_degrees(df$hue), 3), "\n")
    cat("Mean Lightness:", round(mean(df$lightness, na.rm = TRUE), 3), "\n")
    cat("Mean Chroma:", round(mean(df$chroma, na.rm = TRUE), 3), "\n\n")
    
    if (mean(df$z, na.rm = TRUE) > 0) {
      cat("Overall interpretation: this song leans more constricted than diffused on average.")
    } else if (mean(df$z, na.rm = TRUE) < 0) {
      cat("Overall interpretation: this song leans more diffused than constricted on average.")
    } else {
      cat("Overall interpretation: this song appears structurally balanced on average.")
    }
  })
  
  # -------------------------
  # GROUPED SONG COMPARISON TABLE
  # -------------------------
  all_song_summaries <- reactive({
    req(deam_loaded())
    
    song_ids <- intersect(deam_loaded()$valence$song_id, deam_loaded()$arousal$song_id)
    song_ids <- sort(song_ids)
    
    summaries <- lapply(song_ids, function(id) {
      df <- get_song_time_series(id, deam_loaded())
      if (is.null(df)) return(NULL)
      
      mean_theta <- circular_mean_degrees(df$theta)
      mean_z <- mean(df$z, na.rm = TRUE)
      mean_r <- mean(df$r, na.rm = TRUE)
      
      mean_hue <- mean_theta
      mean_lightness <- map_z_to_lightness(mean_z)
      mean_chroma <- map_r_to_chroma(mean_r)
      mean_hex <- lch_to_hex(mean_lightness, mean_chroma, mean_hue)
      
      dominant_label <- get_feelings_label(mean_theta)$emotion
      nearby_labels <- top_plutchik_labels(df$theta, top_n = 3)
      
      interpretation_group <- if (mean_z > 0.10) {
        "Toward Constriction"
      } else if (mean_z < -0.10) {
        "Toward Defusion"
      } else {
        "Balanced"
      }
      
      data.frame(
        Song_ID = id,
        Average_Angle = round(mean_theta, 2),
        Average_Z = round(mean_z, 3),
        Average_R = round(mean_r, 3),
        Representative_Hue = round(mean_hue, 2),
        Representative_Color = mean_hex,
        Dominant_Label = dominant_label,
        Nearby_Labels = nearby_labels,
        Interpretation_Group = interpretation_group,
        Interpretation = interpret_song_summary(mean_z, mean_r, mean_theta),
        stringsAsFactors = FALSE
      )
    })
    
    summaries <- summaries[!sapply(summaries, is.null)]
    do.call(rbind, summaries)
  })
  
  output$balanced_song_ui <- renderUI({
    req(all_song_summaries())
    
    balanced_choices <- all_song_summaries()
    balanced_choices <- balanced_choices[balanced_choices$Interpretation_Group == "Balanced", ]
    
    selectInput(
      "balanced_song",
      "Balanced Song",
      choices = balanced_choices$Song_ID,
      selected = if (nrow(balanced_choices) > 0) balanced_choices$Song_ID[1] else NULL
    )
  })
  
  output$diffused_song_ui <- renderUI({
    req(all_song_summaries())
    
    diffused_choices <- all_song_summaries()
    diffused_choices <- diffused_choices[diffused_choices$Interpretation_Group == "Toward Defusion", ]
    
    selectInput(
      "diffused_song",
      "Toward Defusion",
      choices = diffused_choices$Song_ID,
      selected = if (nrow(diffused_choices) > 0) diffused_choices$Song_ID[1] else NULL
    )
  })
  
  output$constricted_song_ui <- renderUI({
    req(all_song_summaries())
    
    constricted_choices <- all_song_summaries()
    constricted_choices <- constricted_choices[constricted_choices$Interpretation_Group == "Toward Constriction", ]
    
    selectInput(
      "constricted_song",
      "Toward Constriction",
      choices = constricted_choices$Song_ID,
      selected = if (nrow(constricted_choices) > 0) constricted_choices$Song_ID[1] else NULL
    )
  })
  
  output$song_comparison_table_ui <- renderUI({
    req(all_song_summaries(), input$balanced_song, input$diffused_song, input$constricted_song)
    
    chosen_ids <- unique(as.numeric(c(
      input$balanced_song,
      input$diffused_song,
      input$constricted_song
    )))
    
    comparison_df <- all_song_summaries()
    comparison_df <- comparison_df[comparison_df$Song_ID %in% chosen_ids, , drop = FALSE]
    req(nrow(comparison_df) > 0)
    
    comparison_df <- comparison_df[match(chosen_ids, comparison_df$Song_ID), , drop = FALSE]
    
    rows <- lapply(seq_len(nrow(comparison_df)), function(i) {
      row <- comparison_df[i, ]
      
      tags$tr(
        tags$td(row$Interpretation_Group),
        tags$td(row$Song_ID),
        tags$td(row$Average_Angle),
        tags$td(row$Average_Z),
        tags$td(row$Average_R),
        tags$td(row$Representative_Hue),
        tags$td(
          tags$div(
            style = paste0(
              "width:32px; height:20px; background:", row$Representative_Color,
              "; border:1px solid #444; border-radius:4px; display:inline-block; margin-right:8px;"
            )
          ),
          row$Representative_Color
        ),
        tags$td(row$Dominant_Label),
        tags$td(row$Nearby_Labels),
        tags$td(row$Interpretation)
      )
    })
    
    tags$table(
      class = "table table-striped table-bordered",
      tags$thead(
        tags$tr(
          tags$th("Group"),
          tags$th("Song ID"),
          tags$th("Avg Angle"),
          tags$th("Avg Z"),
          tags$th("Avg R"),
          tags$th("Hue"),
          tags$th("Color"),
          tags$th("Dominant Label"),
          tags$th("Nearby Labels"),
          tags$th("Interpretation")
        )
      ),
      tags$tbody(rows)
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