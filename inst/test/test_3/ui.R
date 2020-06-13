#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(rhandsontable)


header <- dashboardHeader(
    title = span(img(src = "poped_splash.png", height = 35), "PopED"),
    disable = FALSE,
    dropdownMenuOutput("messageMenu"),
    dropdownMenu(type = "notifications",badgeStatus = "primary",
                 notificationItem(
                     text = "5 new users today",
                     icon("users")
                 ),
                 notificationItem(
                     text = "12 items delivered",
                     icon("truck"),
                     status = "success"
                 ),
                 notificationItem(
                     text = "Server load at 86%",
                     icon = icon("exclamation-triangle"),
                     status = "warning"
                 )
    ),
    dropdownMenu(type = "tasks", badgeStatus = "success",
                 taskItem(value = 90, color = "green",
                          "Documentation"
                 ),
                 taskItem(value = 17, color = "aqua",
                          "Project X"
                 ),
                 taskItem(value = 75, color = "yellow",
                          "Server deployment"
                 ),
                 taskItem(value = 80, color = "red",
                          "Overall project"
                 )
    )
)

sidebar <- dashboardSidebar(
    disable = FALSE,
    sidebarMenu(
        menuItem("Model definition", tabName = "model_def", icon = icon("bezier-curve")),
        menuItem("Design definition", tabName = "design_def", icon = icon("tablets")),
        menuItem("Tools", icon = icon("toolbox"), startExpanded = TRUE,
                 menuSubItem("Plot model and design", tabName = "plot_model_pred", icon = icon("chart-line"))
        ),
        
        hr(),
        menuItem("Testing", icon = icon("grimace"), tabName = "test",
                 badgeLabel = "new", badgeColor = "green"),
        menuItem("Source code", icon = icon("file-code-o"), 
                 href = "https://andrewhooker.github.io/PopED/",newtab = TRUE),
        hr(),
        menuItem("About PopED", icon = icon("info-circle"), tabName = "about", badgeColor = "green")
    )
)



body <- dashboardBody(
    tabItems(
        # First tab content
        tabItem(tabName = "model_def",
                fluidRow(
                    box(
                        title = "Structural model", 
                        status = "primary", 
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        #background = "maroon",
                        checkboxInput("pk_mod", label = "PK model", value = TRUE), 
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
                        ),
                        checkboxInput("pd_mod", label = "PD model", value = FALSE),
                        conditionalPanel(
                            condition = "input.pd_mod == true",
                            selectInput("DE_model", "Drug effect (DE) Model:",
                                        list(
                                            #"None" = "NULL",
                                            "Linear" = "linear",
                                            "Power" = "power",
                                            "Emax" = "emax",
                                            "Sigmoidal Emax" = "hill"
                                        ),
                                        selected="hill")
                        ),
                        conditionalPanel(
                            condition = "input.pd_mod == true && input.pk_mod == true",
                            selectInput("struct_PD_mod", label = "Structural PD model:", 
                                        list(
                                            "Direct effect (base + DE)" = "direct",
                                            "Effect compartment" = "effect",
                                            "Turnover: inhibit Kin"="inhib_kin",
                                            "Turnover: stimulate Kin"="stim_kin",
                                            "Turnover: inhibit Kout"="inhib_kout",
                                            "Turnover: stimulate Kout"="stim_kout"))
                        )
                    )     
                )
                
        ),
        
        tabItem(tabName = "plot_model_pred",
                fluidRow(
                    box(
                        title = "Controls",
                        status = "primary", 
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        #background = "maroon",
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
                    box(title="Model predictions",
                        status = "primary", 
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        #background = "maroon",
                        plotOutput("modelPlot")
                    )
                )
        ),
        
        
        # Second tab content
        tabItem(tabName = "test",
                h2("Widgets tab content"),
                fluidRow(
                    box(
                        title = "Controls",
                        sliderInput("slider", "Number of observations:", 1, 100, 50)
                    ),
                    box(
                        title = "Histogram", 
                        #status = "primary", 
                        solidHeader = TRUE,
                        collapsible = TRUE, background = "maroon",
                        plotOutput("plot1", height = 250)
                    ),
                    box(title = "Controls again",
                        rHandsontableOutput("hot_parameter_data")
                    ),
                    box(
                        title = "Histogram 2", 
                        #status = "primary", 
                        solidHeader = TRUE,
                        collapsible = TRUE,# background = "maroon",
                        plotOutput("plot2")
                    )
                    
                )
        ),
        tabItem(tabName = "about",
                
                box(
                    fluidRow(
                        column(12, align="center",
                               img(src = "poped_splash.png", height = 72, width = 72),
                               a(paste("PopED for R (", packageVersion("PopED"),")",sep=""), 
                                 href = "https://andrewhooker.github.io/PopED/index.html",
                                 target="_blank"),
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
        
    )
)

dashboardPage(header, sidebar, body)