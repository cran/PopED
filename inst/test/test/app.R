#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

## this

# UI ----------------------------------------------------------------------
library(shiny)
#library(shinythemes)
ui <- navbarPage(
    "test",
    collapsible = TRUE,
    #theme=shinytheme("cerulean"),
    tabPanel(
        "Old Faithful Geyser Data",
        sidebarLayout(
            sidebarPanel(
                sliderInput("bins",
                            "Number of bins:",
                            min = 1,
                            max = 50,
                            value = 30),
                rHandsontableOutput("hot_parameter_data"),
                br(),
                wellPanel(
                    rHandsontableOutput("hot_parameter_data_2")
                )
            ),
            
            # Show a plot of the generated distribution
            mainPanel(
                #shinythemes::themeSelector(),  # <--- Add this somewhere in the UI
                wellPanel(plotOutput("distPlot"),
                          sliderInput("bins2",
                                      "Number of bins:",
                                      min = 1,
                                      max = 50,
                                      value = 30))
            )
        )
    ),
    navbarMenu("More",
               tabPanel("Summary"),
               "----",
               "Section header",
               tabPanel("Table")
    ),
    footer = list(
        fluidRow(
            column(12, align="center",
                   hr(),
                   img(src = "poped_splash.png", height = 72, width = 72),
                   a(paste("PopED for R (", packageVersion("PopED"),")",sep=""), 
                     href = "https://andrewhooker.github.io/PopED/index.html"),
                   div(tags$small(
                       img(src = "", height = 2, width = 3),
                       "(c) 2014-2016, Andrew C. Hooker,",
                       tags$br(),
                       img(src = "", height = 2, width = 3),
                       "Pharmacometrics Research Group,",
                       tags$br(),
                       img(src = "", height = 2, width = 3),
                       "Uppsala University,",
                       tags$br(),
                       img(src = "", height = 2, width = 3),
                       "Sweden")
                   ))))
)



# server ------------------------------------------------------------------
server <- function(input, output) {
    
    parameter_data = reactive({
        input_data <- input$hot_parameter_data
        if (!is.null(input_data)) {
            DF = hot_to_r(input_data)
        } else {
            DF = data.frame(bins = 30, 
                            times = 10,
                            stringsAsFactors = FALSE)
        }
        DF
    })
    
    
    output$hot_parameter_data = renderRHandsontable({
        DF <- parameter_data()
        if(!is.null(DF)){
            rhandsontable(DF,overflow="visible") 
        }
    })
    
    parameter_data_2 = reactive({
        input_data <- input$hot_parameter_data_2
        if (!is.null(input_data)) {
            DF = hot_to_r(input_data)
        } else {
            DF = data.frame(bins = 30, 
                            times = 10,
                            stringsAsFactors = FALSE)
        }
        DF
    })
    
    
    output$hot_parameter_data_2 = renderRHandsontable({
        DF <- parameter_data_2()
        if(!is.null(DF)){
            rhandsontable(DF,overflow="visible") 
        }
    })
    
    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        # bins <- seq(min(x), max(x), length.out = input$bins + 1)
        bins <- seq(min(x), max(x), length.out = parameter_data_2()$bins[1] + 1)
        
        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
