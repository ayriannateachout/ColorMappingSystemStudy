library(shiny)

page2_ui <- fluidPage(
  
  titlePanel("Emotional Structure and Continuous Representation"),
  
  h3("Context"),
  p("Emotional systems have often been described using discrete categories. These structures provide a shared language, allowing people to recognize, label, and communicate emotional experience in consistent ways. Frameworks such as Plutchik’s Wheel of Emotions organize these categories into relationships, where proximity reflects similarity and opposition reflects contrast."),
  
  p("This approach is valuable for clarity. It simplifies complex internal states into recognizable forms. However, when emotional experience is observed over time or across multiple dimensions, additional structure begins to emerge."),
  
  tags$img(src = "CM3dModel.png", style = "max-width:100%; height:auto; margin-bottom:20px;"),
  
  h3("Discrete Representation"),
  p("In two-dimensional form, emotions are arranged around a circle, with intensity represented as distance from the center. In three-dimensional form, this structure is extended into a cone, where intensity increases along a vertical axis."),
  
  p("These models support categorization, but they introduce constraints. Emotional states are separated into defined groups, and variation is primarily expressed as changes in intensity within those groups."),
  
  tags$ul(
    tags$li("transitions between emotions appear as jumps between categories"),
    tags$li("intensity is expressed in a single direction"),
    tags$li("structural differences in how emotions are experienced are not explicitly represented")
  ),
  
  h3("Observed Behavior in Continuous Data"),
  p("When emotional signals are examined as continuous data, a different pattern appears. Instead of isolated states, emotional trajectories tend to move gradually, with direction, persistence, and structural variation over time."),
  
  p("In time-series analysis of valence and arousal, emotional change often appears as sustained movement rather than rapid switching. Signals show continuity, clustering, and memory, where nearby states influence one another."),
  
  p("In one observed case, emotional direction shifted steadily over time rather than alternating between positive and negative categories. Larger changes appeared as structured transitions rather than isolated spikes, suggesting a coherent trajectory rather than discrete jumps."),
  
  p("Further analysis showed that emotional signals retained temporal dependence, where each moment was strongly influenced by the one before it. This suggests that emotional experience behaves more like a continuous process than a sequence of independent labels."),
  
  h3("Discrete vs Continuous Interpretation"),
  p("When the same emotional signal is converted into discrete categories, much of this structure is lost. Continuous variation in timing, strength, and shape is reduced to a small number of labels."),
  
  p("In practice, this can compress an entire emotional trajectory into a single category, even when meaningful variation exists within it. Gradual shifts, plateaus, and structural changes become difficult to observe."),
  
  p("This suggests that discrete systems are effective for communication, but may not fully capture the underlying dynamics of emotional experience."),
  
  h3("Spatial Interpretation"),
  p("A continuous perspective allows emotional states to be understood as positions within a space rather than fixed labels. In this view, multiple dimensions can exist simultaneously."),
  
  tags$ul(
    tags$li("direction can be represented as angular position"),
    tags$li("structure can vary along a vertical axis"),
    tags$li("intensity can be represented as magnitude")
  ),
  
  tags$img(src = "CMMathModel.png", style = "max-width:100%; height:auto; margin-bottom:20px;"),
  
  h3("Color as a Continuous Medium"),
  p("Color provides a natural way to represent continuous variation. Unlike discrete categories, color exists as a smooth spectrum, where small changes produce gradual perceptual differences."),
  
  p("Hue allows directional variation, forming a circular structure similar to emotional categories. Lightness introduces vertical variation, allowing states to appear more constrained or more diffuse. Chroma reflects intensity, increasing or decreasing saturation without changing structure."),
  
  p("Together, these dimensions allow for interpolation between states, where emotional positions are not limited to predefined labels but can exist anywhere within a continuous field."),
  
  tags$img(src = "CMwedges.png", style = "max-width:100%; height:auto; margin-bottom:20px;"),
  
  h3("Interpretation"),
  p("This perspective does not replace discrete emotional models. Instead, it extends them. Discrete systems provide clarity and shared meaning, while continuous representations preserve nuance, transition, and structure."),
  
  p("By combining these approaches, emotional representation can move beyond fixed categories toward a system that reflects both recognizable patterns and the continuous nature of human experience.")
)