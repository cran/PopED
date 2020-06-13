#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
if(Sys.getenv("LOGNAME")=="andrewhooker") devtools::load_all("~/Documents/_PROJECTS/PopED/repos/PopED/")
library(PopED)
library(rhandsontable)


# Define server logic required to draw a histogram
function(input, output) {
    set.seed(122)
    histdata <- rnorm(500)
    
    output$plot1 <- renderPlot({
        data <- histdata[seq_len(input$slider)]
        hist(data)
    })
    
    messageData <- data.frame(
        from = c("Admininstrator", "New User", "Support"),
        message = c(
            "Sales are steady this month.",
            "How do I register?",
            "The new server is ready."
        ),
        stringsAsFactors = FALSE
    )
    
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
            rhandsontable(DF)#,overflow="visible") 
        }
    })
    
    output$plot2 <- renderPlot({
        data <- histdata[seq_len(parameter_data()$bins[1])]
        hist(data)
    })
    
    output$messageMenu <- renderMenu({
        # Code to generate each of the messageItems here, in a list. This assumes
        # that messageData is a data frame with two columns, 'from' and 'message'.
        msgs <- apply(messageData, 1, function(row) {
            messageItem(from = row[["from"]], message = row[["message"]])
        })
        
        # This is equivalent to calling:
        #   dropdownMenu(type="messages", msgs[[1]], msgs[[2]], ...)
        dropdownMenu(type = "messages", .list = msgs)
    })
    
    create_db <- reactive({
        
        model_def <- list(
            ff_fun="ff.PK.1.comp.oral.sd.CL",
            fg_fun=build_sfg(model="ff.PK.1.comp.oral.sd.CL"),
            fError_fun="feps.prop")
        
        par_def <- list(
            bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
            notfixed_bpop=c(1,1,1,0),
            d=c(CL=0.07, V=0.02, KA=0.6), 
            sigma=c(prop=0.01))
        # bpop = bpop,
        # notfixed_bpop=notfixed_bpop,
        # d=d_vec,
        # notfixed_d = notfixed_d,
        # covd = covd,
        # notfixed_covd=notfixed_covd,
        # sigma = sigma_mat,
        # notfixed_sigma = notfixed_sigma)
        
        design_def <- list(groupsize=32,
                           xt=c( 0.5,1,2,6,24,36,72,120),
                           minxt=0,
                           maxxt=120,
                           a=70,
                           mina=0,
                           maxa=100)
        
        do.call(create.poped.database,
                c(model_def,
                  par_def,
                  design_def)
        )
    })
    
    pmp_plot <- eventReactive(input$update_pmp, {
        poped_db <- create_db()
        plot <- plot_model_prediction(poped_db,
                                      PI= input$PI,
                                      IPRED= input$IPRED,
                                      DV= input$DV,
                                      separate.groups= input$separate.groups,
                                      model_num_points =  input$model_num_points)
    })
    
    
    output$modelPlot <- renderPlot({
        print(pmp_plot())
    })
}
