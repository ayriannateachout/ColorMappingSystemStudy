page1_ui <- fluidPage(
  
  titlePanel("Color Mapping Prototype — Affective LCh System"),
  
  h3("Dataset Status & Normalization (Review 2)"),
  verbatimTextOutput("file_status"),
  verbatimTextOutput("norm_stats"),
  
  # keep the rest of your current page 1 UI here
)