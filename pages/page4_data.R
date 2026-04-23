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
  p("These values show how each time point is translated from valence and arousal into constriction, defusion, structural position, and angular direction."),
  tableOutput("model_applied_table"),
  
  hr(),
  
  h3("5. Time-Series Overview"),
  p("These plots preserve temporal movement. They show that emotional structure changes gradually across the song rather than appearing as isolated static labels."),
  plotOutput("valence_arousal_plot", height = "300px"),
  plotOutput("structure_plot", height = "300px"),
  
  hr(),
  
  h3("6. Sphere Coordinate Mapping"),
  p("This table shows how each observation is translated into sphere coordinates. The equator corresponds to emotional direction, the vertical axis corresponds to constriction versus defusion, and color emerges from hue, lightness, and chroma."),
  p("Within this mapping, darker values reflect upward movement toward constriction, while lighter values reflect downward movement toward defusion."),
  tableOutput("sphere_table"),
  
  hr(),
  
  h3("7. 2D Sphere Coordinate View"),
  p("This plot treats the emotional circle as the horizontal axis and constriction versus defusion as the vertical axis. It serves as a 2D view of the developing sphere before a full 3D model is introduced."),
  plotOutput("sphere_coordinate_plot", height = "400px"),
  
  hr(),
  
  h3("8. Song-Level Interpretation"),
  p("This section summarizes how the selected song behaves in the sphere model as a whole, rather than only at individual time points."),
  verbatimTextOutput("sphere_interpretation"),
  
  hr(),
  
  h3("9. Summary Checks"),
  p("These summary values show the average position of the selected song across the modeled dimensions."),
  verbatimTextOutput("data_summary_output"),
  
  hr(),
  
  hr(),
  
  h3("10. Three-Song Comparison Table"),
  p("This section compares three songs by structural tendency: one relatively balanced song, one song leaning toward defusion, and one song leaning toward constriction."),
  p("This helps show how the model can summarize songs into readable emotional signatures without flattening them into rigid labels."),
  
  fluidRow(
    column(
      width = 4,
      uiOutput("balanced_song_ui")
    ),
    column(
      width = 4,
      uiOutput("diffused_song_ui")
    ),
    column(
      width = 4,
      uiOutput("constricted_song_ui")
    )
  ),
  
  br(),
  
  uiOutput("song_comparison_table_ui")
)
