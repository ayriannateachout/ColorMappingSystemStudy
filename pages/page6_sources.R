library(shiny)

page6_ui <- fluidPage(
  
  titlePanel("References"),
  
  hr(),
  
  h3("Datasets and Technical Resources"),
  tags$p(
    "Aljanaki, A., Yang, Y. H., & Soleymani, M. (2017). ",
    tags$em("Developing a benchmark for emotional analysis of music: The DEAM dataset. "),
    "Retrieved from ",
    tags$a("https://cvml.unige.ch/databases/DEAM/", href = "https://cvml.unige.ch/databases/DEAM/", target = "_blank")
  ),
  
  tags$p(
    "GeeksforGeeks. (n.d.). ",
    tags$em("Sphere mathematics. "),
    "Retrieved from ",
    tags$a("https://www.geeksforgeeks.org/maths/sphere/", href = "https://www.geeksforgeeks.org/maths/sphere/", target = "_blank")
  ),
  
  hr(),
  
  h3("Psychology and Cognitive Research"),
  tags$p(
    "Germine, L., et al. (n.d.). ",
    tags$em("A massive dataset of the NeuroCognitive Performance Test: A web-based cognitive assessment. "),
    "Retrieved from ",
    tags$a("https://www.researchgate.net/publication/366124781_A_massive_dataset_of_the_NeuroCognitive_Performance_Test_a_web-based_cognitive_assessment",
           href = "https://www.researchgate.net/publication/366124781_A_massive_dataset_of_the_NeuroCognitive_Performance_Test_a_web-based_cognitive_assessment",
           target = "_blank")
  ),
  
  tags$p(
    "Stanford University. (2025). ",
    tags$em("AI, color, and human thinking. "),
    "Retrieved from ",
    tags$a("https://news.stanford.edu/stories/2025/09/ai-colors-human-thinking-research",
           href = "https://news.stanford.edu/stories/2025/09/ai-colors-human-thinking-research",
           target = "_blank")
  ),
  
  hr(),
  
  h3("Color Theory"),
  tags$p(
    "Color Matters. (n.d.). ",
    tags$em("Basic color theory. "),
    "Retrieved from ",
    tags$a("https://colormatters.com/color-and-design/basic-color-theory",
           href = "https://colormatters.com/color-and-design/basic-color-theory",
           target = "_blank")
  ),
  
  hr(),
  
  h3("Computer Science Foundations"),
  tags$p(
    "Tanenbaum, A. S., & Austin, T. (2012). ",
    tags$em("Structured computer organization (6th ed.). "),
    "Pearson."
  ),
  
  tags$p(
    "Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). ",
    tags$em("Operating system concepts (10th ed.). "),
    "Wiley."
  ),
  
  hr(),
  
  h3("Conceptual Influence"),
  tags$p(
    "Donnelly, K. (Host). (n.d.). ",
    tags$em("The descent of artificial intelligence [Podcast].")
  ),
  
  hr(),
  
  h3("Note"),
  p("These references include datasets, theoretical materials, and conceptual influences used to support the development of the model. Some sources provide direct empirical grounding, while others inform interpretation and broader context.")
)