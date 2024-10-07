## ----setup, include = FALSE---------------------------------------------------

if(Sys.getenv("LOGNAME")=="ancho179") devtools::load_all("~/Documents/_PROJECTS/PopED/repo/PopED/")

set.seed(1234)

knitr::opts_chunk$set(
  collapse = TRUE
  , comment = "#>"
  #, fig.width=6
  , cache = TRUE
)

## ----eval=FALSE---------------------------------------------------------------
#  system.file("examples", package="PopED")

## ----eval=FALSE---------------------------------------------------------------
#  ex_dir <- system.file("examples", package="PopED")
#  list.files(ex_dir)

## ----eval=FALSE---------------------------------------------------------------
#  file_name <- "ex.1.a.PK.1.comp.oral.md.intro.R"
#  ex_file <- system.file("examples",file_name,package="PopED")
#  file.copy(ex_file,tempdir(),overwrite = T)
#  file.edit(file.path(tempdir(),file_name))

## ----eval=TRUE----------------------------------------------------------------
library(PopED)
packageVersion("PopED")

## ----struct_model-------------------------------------------------------------
ff <- function(model_switch,xt,parameters,poped.db){
  with(as.list(parameters),{
    N = floor(xt/TAU)+1
    f=(DOSE*Favail/V)*(KA/(KA - CL/V)) * 
      (exp(-CL/V * (xt - (N - 1) * TAU)) * (1 - exp(-N * CL/V * TAU))/(1 - exp(-CL/V * TAU)) - 
         exp(-KA * (xt - (N - 1) * TAU)) * (1 - exp(-N * KA * TAU))/(1 - exp(-KA * TAU)))  
    return(list( f=f,poped.db=poped.db))
  })
}

## -----------------------------------------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  parameters=c( V=bpop[1]*exp(b[1]),
                KA=bpop[2]*exp(b[2]),
                CL=bpop[3]*exp(b[3]),
                Favail=bpop[4],
                DOSE=a[1],
                TAU=a[2])
}

## -----------------------------------------------------------------------------
feps <- function(model_switch,xt,parameters,epsi,poped.db){
  returnArgs <- ff(model_switch,xt,parameters,poped.db) 
  f <- returnArgs[[1]]
  poped.db <- returnArgs[[2]]
 
  y = f*(1+epsi[,1])+epsi[,2]
  
  return(list(y=y,poped.db=poped.db)) 
}

## -----------------------------------------------------------------------------
poped.db <- create.poped.database(
  # Model
  ff_fun=ff,
  fg_fun=sfg,
  fError_fun=feps,
  bpop=c(V=72.8,KA=0.25,CL=3.75,Favail=0.9), 
  notfixed_bpop=c(1,1,1,0),
  d=c(V=0.09,KA=0.09,CL=0.25^2), 
  sigma=c(prop=0.04,add=5e-6),
  notfixed_sigma=c(1,0),
  
  # Design
  m=2,
  groupsize=20,
  a=list(c(DOSE=20,TAU=24),c(DOSE=40, TAU=24)),
  maxa=c(DOSE=200,TAU=24),
  mina=c(DOSE=0,TAU=24),
  xt=c( 1,2,8,240,245),
  
  # Design space
  minxt=c(0,0,0,240,240),
  maxxt=c(10,10,10,248,248),
  bUseGrouped_xt=TRUE)

## ----simulate_without_BSV-----------------------------------------------------
plot_model_prediction(poped.db, model_num_points = 300)

## ----simulate_with_BSV--------------------------------------------------------
plot_model_prediction(poped.db, 
                      PI=TRUE, 
                      separate.groups=T, 
                      model_num_points = 300, 
                      sample.times = FALSE)

## -----------------------------------------------------------------------------
dat <- model_prediction(poped.db,DV=TRUE)
head(dat,n=5);tail(dat,n=5)

## -----------------------------------------------------------------------------
(ds1 <- evaluate_design(poped.db))

## -----------------------------------------------------------------------------
poped.db.new <- create.poped.database(
  # Model
  ff_fun=ff,
  fg_fun=sfg,
  fError_fun=feps,
  bpop=c(V=72.8,KA=0.25,CL=3.75,Favail=0.9), 
  notfixed_bpop=c(1,1,1,0),
  d=c(V=0.09,KA=0.09,CL=0.25^2), 
  sigma=c(prop=0.04,add=5e-6),
  notfixed_sigma=c(1,0),
  
  # Design
  m=2,
  groupsize=20,
  a=list(c(DOSE=20,TAU=24),c(DOSE=40, TAU=24)),
  maxa=c(DOSE=200,TAU=24),
  mina=c(DOSE=0,TAU=24),
  xt=c( 1,2,245),
                                      
  # Design space
  minxt=c(0,0,240),
  maxxt=c(10,10,248),
  bUseGrouped_xt=TRUE)

## -----------------------------------------------------------------------------
(ds2 <- evaluate_design(poped.db.new))

## ----results='hide'-----------------------------------------------------------
(design_eval <- round(data.frame("Design 1"=ds1$rse,"Design 2"=ds2$rse)))

## ----design_summary,echo=FALSE------------------------------------------------
knitr::kable(design_eval) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## -----------------------------------------------------------------------------
efficiency(ds2$ofv,ds1$ofv,poped.db)

## ----optimize,message = FALSE,results='hide'----------------------------------
output <- poped_optim(poped.db, opt_xt=TRUE)

## ----simulate_optimal_design--------------------------------------------------
summary(output)
plot_model_prediction(output$poped.db)

## ----simulate_efficiency_windows,fig.width=6,fig.height=6---------------------
plot_efficiency_of_windows(output$poped.db,xt_windows=0.5)

## ----message = FALSE,results='hide'-------------------------------------------
poped.db.discrete <- create.poped.database(poped.db,discrete_xt = list(c(0:10,240:248)))
                                          
output_discrete <- poped_optim(poped.db.discrete, opt_xt=TRUE)


## ----simulate_discrete_optimization-------------------------------------------
summary(output_discrete)
plot_model_prediction(output_discrete$poped.db, model_num_points = 300)

## ----optimize_dose,message = FALSE,results='hide', eval=FALSE-----------------
#  output_dose_opt <- poped_optim(output$poped.db, opt_xt=TRUE, opt_a=TRUE)

## -----------------------------------------------------------------------------
crit_fcn <- function(poped.db,...){
  pred_df <- model_prediction(poped.db)
  sum((pred_df[pred_df["Time"]==240,"PRED"] - c(0.2,0.35))^2)
}
crit_fcn(output$poped.db)

## ----cost_optimization, message = FALSE,results='hide',cache=TRUE-------------
output_cost <- poped_optim(poped.db, opt_a = TRUE, opt_xt = FALSE,
                     ofv_fun=crit_fcn, 
                     maximize = FALSE)

## ----simulate_cost_optmization------------------------------------------------
summary(output_cost)

## -----------------------------------------------------------------------------
library(ggplot2)
plot_model_prediction(output_cost$poped.db, model_num_points = 300)+
  coord_cartesian(xlim=c(230,250))

