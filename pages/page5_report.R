library(shiny)

page5_ui <- fluidPage(
  
  titlePanel("Model Validation and Real-World Meaning"),
  
  p("This page can explain how the emotional color mapping model can be interpreted, validated, and understood within real-world human-computer interaction contexts. The main goal here is not to claim that the model perfectly measures emotion, but to show how it can support a more continuous and transparent way of representing emotional structure."),
  
  hr(),
  
  h3("1. Purpose"),
  p("The model was developed to explore whether emotional data can be represented as a continuous structure rather than only as separate labels or discrete categorical structures. This page focuses on emotional state accuracy, validation, real-world use, and ethical meaning."),
  
  p("The model uses valence and arousal as starting signals, then translates them into angular direction, structural position, magnitude, and color. These outputs are intended to make emotional variation easier to inspect without reducing the whole experience to one fixed category."),
  
  hr(),
  
  h3("2. Model Validation"),
  p("Validation in this project is approached through consistency and interpretability. The model here is exploratory and the goal is not to prove a final universal emotional formula. The goal is to examine whether the outputs behave in a reasonable and explainable way when applied to continuous emotional data."),
  
  tags$ul(
    tags$li("Similar emotional patterns should produce similar coordinates."),
    tags$li("Changes over time should appear as movement rather than random jumps."),
    tags$li("The representative color should reflect the average emotional structure of the song."),
    tags$li("The Plutchik label should be treated as a comparison label, not as the only meaning of the state.")
  ),
  
  p("This makes the model more transparent. A user can see how the emotional input becomes a coordinate, how the coordinate becomes a color, and how the color can be interpreted."),
  
  hr(),
  
  h3("3. Emotional and State Accuracy"),
  p("The model treats emotional states as positions in a continuous space. This is important because emotional experience is rarely limited to one clean category. A person can experience mixed, shifting, or layered states that are difficult to represent with a single label."),
  
  p("The vertical axis of the model represents constriction and defusion. Constricted states are interpreted as more concentrated, rigid, or intense. Diffused states are interpreted as more open, dispersed, or low-pressure. Balanced states fall between these two tendencies."),
  
  p("This allows the model to describe differences that a simple label may miss. For example, two observations may both be near a similar emotional family, but one may be more constricted while the other may be more diffused."),
  
  hr(),
  
  h3("4. State, Memory, and Cognition"),
  p("Human experience can be understood as state-dependent. A current emotional or cognitive state may influence how information is noticed, interpreted, remembered, and acted upon."),
  
  p("This can be carefully compared to a computer system. A computer does not process information in isolation. Its current state affects how new input is handled and what output is produced. In a similar way, human perception and response are influenced by current internal conditions."),
  
  p("This comparison is only a conceptual analogy. Humans are not computers, and emotional experience cannot be reduced to machine processing. However, the analogy is useful because it shows why state matters. A change in state can change how new information is processed."),
  
  p("In human experience, there is also no completely static moment. Time continues, the body changes, memory updates, and new experiences affect the next state. Even when there is little external stimulation, internal processes continue to shift over time."),
  
  p("For this reason, emotion may be better represented as an ongoing process rather than a single isolated label. This supports the use of continuous models that preserve movement, intensity, and structure."),
  
  hr(),
  
  h3("5. Real-World Implementation"),
  p("In real-world systems, this model could be used as an interpretive layer for emotional data. It could help systems show emotional structure more transparently instead of only assigning broad categories such as positive, negative, or neutral."),
  
  tags$ul(
    tags$li("In human-computer interaction, it could support interfaces that respond to emotional patterns over time."),
    tags$li("In music or media analysis, it could visualize emotional movement across a song, video, or experience."),
    tags$li("In reflective tools, it could help users understand patterns in emotional state without forcing one fixed label."),
    tags$li("In research settings, it could provide a visual way to compare emotional structure across observations.")
  ),
  
  p("The model should be used carefully as, emotional data is sensitive. The model supports the idea that any system that interprets emotion should prioritize transparency, consent, and user understanding."),
  
  hr(),
  
  h3("6. Human-Computer Interaction and Digital Influence"),
  p("Modern digital systems often use psychological principles to shape attention, behavior, and engagement. Interface design, recommendation systems, advertising, and social platforms can all influence emotional state."),
  
  p("This matters because many people interact with psychologically designed systems before they have formal education about psychology, persuasive technology, or emotional influence. As artificial intelligence becomes more common, these effects may become more personalized and more difficult to notice."),
  
  p("This project does not claim to solve those concerns. Instead, it points toward the need for clearer tools that make emotional structure more visible. A model that shows how emotion changes across time may help users and designers better understand how digital experiences affect human state."),
  
  p("The ethical goal is not to use emotional modeling to manipulate people. The goal is to support interpretation, reflection, and more responsible design."),
  
  hr(),
  
  h3("7. Limitations"),
  p("This model is exploratory and it should not be treated as a clinical tool or as a complete measurement of human emotion. Valence and arousal are useful signals, but they cannot capture the full complexity of lived experience."),
  
  tags$ul(
    tags$li("The model depends on how valence and arousal are measured."),
    tags$li("The constriction and defusion formulas are interpretive and should be tested further."),
    tags$li("The Plutchik labels are used as a reference layer, not as final truth."),
    tags$li("The color mapping is a visual representation, not a direct measurement of emotion.")
  ),
  
  p("These limitations here can be important because they keep the model honest and to support interpretation, not to overstate certainty."),
  
  hr(),
  
  h3("8. Conclusion"),
  p("This project presents emotion as a continuous and state-based process. By combining emotional direction, structural position, intensity, and color, the model provides a way to represent nuance that may be lost in strictly discrete systems."),
  
  p("The model connects psychological interpretation, color mapping, and human-computer interaction. It offers a foundation for future work that could further test emotional accuracy, compare more songs or datasets, and explore a full three-dimensional sphere representation."),
  
  p("This model study supports a mindful approach to emotional technology. It suggests that digital systems should not only process and expand emotional data, but should also add more clarity on emotional influence to understand, question, and reflect on.")
)