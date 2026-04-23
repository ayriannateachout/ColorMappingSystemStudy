library(shiny)

page4_ui <- fluidPage(
  
  titlePanel("Data Implementation"),
  
  p("This page applies the continuous emotional model to observed data and allows for inspection of how the model behaves across a dataset."),
  
  hr(),
  
  h3("1. Data Loading"),
  verbatimTextOutput("data_status"),
  
  hr(),
  
  h3("2. Data Preview"),
  tableOutput("data_preview"),
  
  hr(),
  
  h3("3. Model Applied to Data"),
  p("This table shows how the model transforms valence and arousal into continuous emotional structure."),
  tableOutput("model_applied_table"),
  
  hr(),
  
  h3("4. Summary Overview"),
  verbatimTextOutput("data_summary_output")
)