library(shiny)

# load pages
source("pages/page1_prototype.R")
source("pages/page2_research.R")
source("pages/page3_formula.R")
source("pages/page4_data.R")

navbarPage(
  "Color Mapping System Study",
  
  tabPanel("Prototype", page1_ui),
  tabPanel("Research", page2_ui),
  tabPanel("Formula", page3_ui),
  tabPanel("Data", page4_ui)
)
