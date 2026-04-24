library(shiny)

source("pages/page1_prototype.R")
source("pages/page2_research.R")
source("pages/page3_formula.R")
source("pages/page4_data.R")
source("pages/page5_report.R")
source("pages/page6_sources.R")

custom_css <- tags$head(
  tags$style(HTML("
    
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background-color: #ffffff;
      color: #2b1e1a;
      line-height: 1.6;
    }

    .navbar {
      background-color: #3b2a24;
      border: none;
    }

    .navbar-default .navbar-brand {
      color: #e6e0ff !important;
      font-weight: 500;
    }

    .navbar-default .navbar-nav > li > a {
      color: #f5f5f5 !important;
    }

    .navbar-default .navbar-nav > li > a:hover {
      color: #c5c7ff !important;
    }

    .container-fluid {
      max-width: 1200px;
      margin: auto;
    }

    h1, h2, h3 {
      color: #3b2a24;
      margin-top: 28px;
    }

    p {
      font-size: 16px;
      max-width: 950px;
    }

    hr {
      border-top: 1px solid #e0d6d2;
      margin-top: 28px;
      margin-bottom: 28px;
    }

    .tab-content {
      background-color: #ffffff;
      padding: 26px;
      border-radius: 14px;
      box-shadow: 0 3px 10px rgba(0,0,0,0.06);
      margin-bottom: 40px;
    }

    table {
      background-color: #ffffff;
      font-size: 14px;
      border: 1px solid #e0d6d2;
    }

    .table thead {
      background-color: #f4f0ff;
      color: #3b2a24;
    }

    .table-striped > tbody > tr:nth-of-type(odd) {
      background-color: #faf7ff;
    }

    pre {
      background-color: #faf7ff;
      border: 1px solid #e0d6d2;
      border-radius: 10px;
      padding: 14px;
      white-space: pre-wrap;
      word-break: break-word;
    }

    .shiny-input-container label {
      color: #3b2a24;
      font-weight: 500;
    }

    input[type='range'] {
      accent-color: #8f94ff;
    }

    .btn {
      background-color: #8f94ff;
      color: white;
      border-radius: 8px;
      border: none;
    }

    .btn:hover {
      background-color: #6f74e8;
      color: white;
    }

  "))
)

navbarPage(
  "Color Mapping System Study",
  
  header = custom_css,
  
  tabPanel("Prototype", page1_ui),
  tabPanel("Research", page2_ui),
  tabPanel("Formula", page3_ui),
  tabPanel("Data", page4_ui),
  tabPanel("Report", page5_ui),
  tabPanel("References", page6_ui)
)
