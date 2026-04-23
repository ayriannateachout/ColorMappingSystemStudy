library(shiny)

page1_ui <- fluidPage(
  
  titlePanel("2D Modeling Prototype"),
  
  p("This page serves as the entry point into the continuous emotional sphere model. The user adjusts valence and arousal, and the model translates those inputs into angular direction, structural position, color, and optional Plutchik interpretation."),
  
  hr(),
  
  h3("1. Input Controls"),
  p("Adjust the values below to explore how emotional direction and activation influence hue, structure, and interpretation."),
  
  fluidRow(
    column(
      width = 6,
      sliderInput(
        "valence_test",
        "Valence",
        min = -1,
        max = 1,
        value = 0,
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
  p("This section shows how the current inputs are translated into angular direction, constriction, defusion, structural axis, and magnitude."),
  verbatimTextOutput("model_inputs_output"),
  verbatimTextOutput("model_structure_output"),
  
  hr(),
  
  h3("3. Current State Snapshot"),
  p("This section gathers the most important current model outputs into one view."),
  tableOutput("state_snapshot_table"),
  
  hr(),
  
  h3("4. 2D Input View"),
  p("This plot shows the current input position in valence-arousal space. It acts as a 2D entry point into the larger sphere model, where angular direction later becomes the equator and structural position becomes the vertical axis."),
  plotOutput("emotion_map_plot", height = "400px"),
  
  hr(),
  
  h3("5. Color Mapping"),
  p("This section shows the resulting color output and the current continuous hue position."),
  verbatimTextOutput("lch_output"),
  verbatimTextOutput("unique_hue_output"),
  verbatimTextOutput("hex_output"),
  uiOutput("color_swatch"),
  
  hr(),
  
  h3("6. Optional Plutchik Comparison"),
  p("This section shows the nearest Plutchik label and its relationship to the current hue position."),
  verbatimTextOutput("wheel_info"),
  
  hr(),
  
  h3("7. Interpretive Summary"),
  p("This section provides a short summary of the current modeled state in plain language."),
  verbatimTextOutput("prototype_interpretation")
)