#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
if(Sys.getenv("LOGNAME")=="andrewhooker") devtools::load_all("~/Documents/_PROJECTS/PopED/repos/PopED/")
library(PopED)
library(rhandsontable)


function(input, output) {
    
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
    
    create_db <- reactive({

        model_def <- list(
            ff_fun="ff.PK.1.comp.oral.sd.CL",
            fg_fun=build_sfg(model="ff.PK.1.comp.oral.sd.CL"),
            fError_fun="feps.add.prop")
        
        par_def <- list(
            bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
            notfixed_bpop=c(1,1,1,0),
            d=c(CL=0.07, V=0.02, KA=0.6), 
            sigma=c(0.01,0.25))
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
