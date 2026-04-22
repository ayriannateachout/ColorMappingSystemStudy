library(shiny)

page3_ui <- fluidPage(
  
  titlePanel("Continuous Emotional Mapping — Model Formulation"),
  
  h3("1. Observational Basis"),
  p("The formulation of this model begins with observation rather than assumption. When emotional signals such as valence and arousal are examined across time, they do not behave as isolated or rapidly switching categories. Instead, they tend to move gradually, showing persistence, directional drift, and structured transitions."),
  
  p("These patterns suggest that emotional experience is better understood as a continuous process rather than a sequence of independent labeled states. Nearby moments are related, and changes occur through movement rather than abrupt jumps."),
  
  h3("2. From Signals to Structure"),
  p("Two primary signals are used as a starting point: valence and arousal. Valence reflects emotional direction, while arousal reflects activation level. Together, they form a two-dimensional space in which emotional states can be located."),
  
  p("However, additional structure emerges when considering how these signals behave together. Some states appear more concentrated and rigid, while others appear more diffuse and open. This suggests the need for a structural axis beyond simple intensity."),
  
  h3("3. Derived Structural Variables"),
  p("To capture this structure, two complementary quantities are defined."),
  
  tags$ul(
    tags$li("Constriction: a measure of how concentrated and intense the emotional state is"),
    tags$li("Defusion: a measure of how diffuse and open the emotional state is")
  ),
  
  p("These are defined using valence (v) and arousal (a) as:"),
  
  verbatimTextOutput("formula1"),
  
  p("These expressions reflect two opposing tendencies. When both valence and arousal are strong, the state becomes more constricted. When both are weak, the state becomes more diffuse."),
  
  h3("4. Vertical Axis Interpretation"),
  p("A single structural dimension can be formed by comparing these two quantities:"),
  
  verbatimTextOutput("formula2"),
  
  p("This produces a bidirectional axis. Positive values indicate more constricted states, while negative values indicate more diffuse states. This differs from traditional models that represent intensity in only one direction."),
  
  h3("5. Continuous Emotional Coordinates"),
  p("Using these components, each emotional state can be represented as a position in a continuous space defined by three dimensions."),
  
  tags$ul(
    tags$li("Angular direction: emotional orientation"),
    tags$li("Vertical structure: constriction versus diffusion"),
    tags$li("Magnitude: overall intensity")
  ),
  
  p("These can be expressed as:"),
  
  verbatimTextOutput("formula3"),
  
  h3("6. Mapping to Color"),
  p("Color provides a natural representation for this space because it is inherently continuous. Each component can be mapped onto a perceptual dimension."),
  
  tags$ul(
    tags$li("Hue corresponds to angular direction"),
    tags$li("Lightness corresponds to vertical structure"),
    tags$li("Chroma corresponds to intensity")
  ),
  
  p("This allows emotional states to be visualized as points within a continuous color field rather than fixed categories."),
  
  h3("7. Interpretation"),
  p("This formulation does not attempt to replace categorical emotional models. Instead, it provides a complementary perspective. Discrete systems offer clarity and shared language, while this continuous model preserves variation, transition, and structure."),
  
  p("By grounding the formulation in observed behavior and simple relationships, the model remains interpretable while supporting a more nuanced representation of emotional dynamics.")
)