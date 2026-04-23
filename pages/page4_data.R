library(shiny)

page4_ui <- fluidPage(
  
  titlePanel("Data Implementation"),
  
  p("This page applies the continuous emotional model to DEAM valence and arousal data and shows how the modeled structure behaves across time and within the developing color sphere framework."),
  
  hr(),
  
  h3("1. Data Status"),
  verbatimTextOutput("data_status"),
  
  hr(),
  
  h3("2. Song Selection"),
  uiOutput("song_selector"),
  
  hr(),
  
  h3("3. Song Data Preview"),
  tableOutput("song_data_preview"),
  
  hr(),
  
  h3("4. Model Applied Across Time"),
  tableOutput("model_applied_table"),
  
  hr(),
  
  h3("5. Time-Series Overview"),
  plotOutput("valence_arousal_plot", height = "300px"),
  plotOutput("structure_plot", height = "300px"),
  
  hr(),
  
  h3("6. Sphere Coordinate Mapping"),
  p("This table shows how each observation is translated into angular direction, vertical structure, intensity, and color coordinates."),
  tableOutput("sphere_table"),
  
  hr(),
  
  h3("7. 2D Sphere Coordinate View"),
  p("This plot treats the emotional circle as the horizontal axis and constriction versus defusion as the vertical axis."),
  plotOutput("sphere_coordinate_plot", height = "400px"),
  
  hr(),
  
  h3("8. Song-Level Interpretation"),
  verbatimTextOutput("sphere_interpretation"),
  
  hr(),
  
  h3("9. Summary Checks"),
  verbatimTextOutput("data_summary_output")
)