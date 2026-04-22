library(shiny)

page1_ui <- fluidPage(
  
  titlePanel("2D Modeling Prototype"),
  
  p("This page allows the user to adjust core emotional inputs and observe how the continuous model responds through interpretation, color, and optional Plutchik labeling."),
  
  hr(),
  
  h3("1. Input Controls"),
  p("Adjust the values below to explore how valence and arousal influence hue, color, and emotional interpretation."),
  
  fluidRow(
    column(
      width = 6,
      sliderInput(
        "valence_test",
        "Valence",
        min = 0,
        max = 1,
        value = 0.5,
        step = 0.01
      )
    ),
    column(
      width = 6,
      sliderInput(
        "arousal_test",
        "Arousal",
        min = 0,
        max = 1,
        value = 0.5,
        step = 0.01
      )
    )
  ),
  
  fluidRow(
    column(
      width = 6,
      checkboxInput(
        "use_wheel",
        "Enable Plutchik label overlay",
        value = TRUE
      )
    ),
    column(
      width = 6,
      checkboxInput(
        "snap_to_emotion",
        "Snap hue to nearest Plutchik label",
        value = FALSE
      )
    )
  ),
  
  hr(),
  
  h3("2. Model Interpretation"),
  p("This section shows how the current inputs are interpreted by the continuous model."),
  verbatimTextOutput("model_inputs_output"),
  verbatimTextOutput("model_structure_output"),
  
  hr(),
  
  h3("3. Current State Snapshot"),
  p("This section gathers the most important current model outputs into one view."),
  tableOutput("state_snapshot_table"),
  
  hr(),
  
  h3("4. 2D Emotional Position"),
  p("This section displays the current point in the 2D model space."),
  plotOutput("emotion_map_plot", height = "400px"),
  
  hr(),
  
  h3("5. Color Mapping"),
  p("This section shows the resulting color output."),
  verbatimTextOutput("lch_output"),
  verbatimTextOutput("unique_hue_output"),
  verbatimTextOutput("hex_output"),
  uiOutput("color_swatch"),
  
  hr(),
  
  h3("6. Optional Plutchik Comparison"),
  p("This section shows the nearest Plutchik label and related hue interpretation."),
  verbatimTextOutput("wheel_info"),
  
  hr(),
  
  h3("7. Interpretive Summary"),
  p("This section provides a short written interpretation of the modeled emotional position."),
  verbatimTextOutput("prototype_interpretation")
  )