#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(rhandsontable)
library(shinyWidgets)

navbarPage(
    title="PopED",
    collapsible = TRUE,
    theme=shinytheme("cerulean"),
    
    
    # Model -------------------------------------------------------------------
    tabPanel("Model",tabsetPanel(
        tabPanel("Model definition", 
                 fluidRow(
                     column(4, offset = 4, 
                            checkboxInput("pk_mod", label = "PK model", value = TRUE),  
                         #h4("PK Model"),
                         conditionalPanel(
                             condition = "input.pk_mod == true",
                             selectInput("struct_PK_model", "Structural PK model:",
                                         choices = list(
                                             #"None"="NULL",
                                             #"1-compartment" = "ff.PK.1.comp.iv",
                                             "1-compartment, 1st-order absorption" = "ff.PK.1.comp.oral"#,
                                             #"2-compartment" = "ff.PK.2.comp.iv",
                                             #"2-compartment, 1st-order absorption" = "ff.PK.2.comp.oral",
                                             #"3-compartment" = "ff.PK.3.comp.iv",
                                             #"3-compartment, 1st-order absorption" = "ff.PK.3.comp.oral"
                                         ),
                                         selected = "ff.PK.1.comp.oral"),
                             selectInput("param_PK_model", "PK model parameterization:",
                                         choices = list(
                                             "Clearace and Volume"="CL",
                                             "Rate constants" = "KE"
                                         ),
                                         selected = "CL")
                         )
                     ),
                     #br(),
                     
                     column(3, 
                            #h4("PD Model"),
                            checkboxInput("pd_mod", label = "PD model", value = FALSE),
                            conditionalPanel(
                                condition = "input.pd_mod == true",
                                selectInput("struct_PD_model", "Structural PD Model:",
                                            list(
                                                #"None" = "NULL",
                                                "Linear" = "linear",
                                                "Emax" = "emax",
                                                "Emax with hill coefficient" = "hill"
                                            ))
                            ),
                            conditionalPanel(
                                condition = "input.pd_mod == true && input.pk_mod == true",
                                selectInput("link_fcn", label = "Link Function", 
                                            list(
                                                "Direct Eeffect" = "direct",
                                                "Effect compartment" = "effect",
                                                "Turnover inhibit Kin"="inhib_kin",
                                                "Turnover stimulate Kin"="stim_kin",
                                                "Turnover inhibit Kout"="inhib_kout",
                                                "Turnover stimulate Kout"="stim_kout"))
                            )
                     )
                 ),
                 
        ),
        tabPanel("test", 
                 br(),
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
        )
    )
    ),
    
    # Design -------------------------------------------------------------------
    tabPanel("Design"),
    
    # Tasks -------------------------------------------------------------------
    tabPanel(
        "Tasks",
        tabsetPanel(
            tabPanel("Plot model/design", 
                     br(),
                     sidebarLayout(
                         sidebarPanel(
                             sliderInput("model_num_points",
                                         "Number of points to plot:",
                                         min = 50,
                                         max = 1000,
                                         value = 300),
                             checkboxInput("PI", "Show approximated PI", FALSE),
                             checkboxInput("DV", "Show simulated PI", FALSE),
                             checkboxInput("IPRED", "Show simulated PI without residual error (IPRED PI)", FALSE),
                             checkboxInput("separate.groups", "Separate Groups", FALSE),
                             actionButton("update_pmp","Update/create plot")
                         ),
                         mainPanel(
                             plotOutput("modelPlot")
                         )
                     )    
            )
        )
    ),
    
    
    # Footer -------------------------------------------------------------------
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
                   )
            )
        )
    )
)
