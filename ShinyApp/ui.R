
suppressPackageStartupMessages(c(
        library(shinythemes),
        library(shiny),
        library(tm),
        library(stringr),
        library(markdown),
        library(stylo)))

shinyUI(navbarPage(h2("Data Science Capstone Project", align = "center"),
                         theme = shinytheme("united"),
                   
############################### ~~~~~~~~1~~~~~~~~ ##############################  
## Tab 1 - Prediction
tabPanel(tags$h4("Word Prediction App"),
         
         tags$head(includeScript("./js/ga-shinyapps-io.js")),
         
         fluidRow(
                 
                 column(3),
                 column(6,
                        tags$div(textInput("text", 
                                  label = h3("Enter your text here:"),
                                  value = ),
                        tags$span(style="color:grey",("[English words only]")),
                        br(),
                        tags$hr(),
                        h3("The predicted next word:"),
                        tags$span(style="color:darkred",
                                  tags$strong(tags$h5(textOutput("predictedWord")))),
                        tags$hr(),
                        h4("What you have entered:"),
                        tags$h5(textOutput("enteredWords")),
                        align="center")
                        ),
                 column(3)
         )
),

############################### ~~~~~~~~2~~~~~~~~ ##############################
## Tab 2 - About 
tabPanel(tags$h4("About This App"),
         fluidRow(
           column(2,
                  p("")),
           column(8,
                  includeMarkdown("./about/about.md")),
           column(2,
                  p(""))
         )
),

############################### ~~~~~~~~F~~~~~~~~ ##############################

## Footer

tags$hr(),

tags$span(style="color:grey", 
          tags$footer( 
                      tags$a(h5
                             ("Developed by:"), h3("Santosh Pawar"), align = "center"), 
                      
                      tags$br(),
                      tags$img(src = 'logos.png'),
                                            align = "center"),
          
          tags$br()
)
)
)
