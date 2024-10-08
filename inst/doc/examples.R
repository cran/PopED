## ----setup, include = FALSE, cache=FALSE--------------------------------------
if(Sys.getenv("LOGNAME")=="ancho179") devtools::load_all("~/Documents/_PROJECTS/PopED/repo/PopED/")
library(deSolve)
library(Rcpp)

knitr::opts_chunk$set(
  collapse = TRUE
  , comment = "#>"
  #, fig.width=6
  , cache = TRUE
  , fig.align = "center"
  , out.width = "80%"
  , autodep=TRUE
)

## ----eval=TRUE----------------------------------------------------------------
ex_dir <- system.file("examples", package="PopED")
list.files(ex_dir)

## ----eval=FALSE---------------------------------------------------------------
#  file_name <- "ex.1.a.PK.1.comp.oral.md.intro.R"
#  
#  ex_file <- system.file("examples",file_name,package="PopED")
#  file.copy(ex_file,tempdir(),overwrite = T)
#  file.edit(file.path(tempdir(),file_name))

## -----------------------------------------------------------------------------
library(PopED)
f_pkpdmodel <- function(model_switch,xt,parameters,poped.db){
  with(as.list(parameters),{
    y=xt
    MS <- model_switch
    
    # PK model
    CONC = DOSE/V*exp(-CL/V*xt) 
    
    # PD model
    EFF = E0 + CONC*EMAX/(EC50 + CONC)
    
    y[MS==1] = CONC[MS==1]
    y[MS==2] = EFF[MS==2]
    
    return(list( y= y,poped.db=poped.db))
  })
}

## -----------------------------------------------------------------------------
## -- Residual Error function
## -- Proportional PK + additive PD
f_Err <- function(model_switch,xt,parameters,epsi,poped.db){
  returnArgs <- do.call(poped.db$model$ff_pointer,list(model_switch,xt,parameters,poped.db)) 
  y <- returnArgs[[1]]
  poped.db <- returnArgs[[2]]
  
  MS <- model_switch
  
  prop.err <- y*(1+epsi[,1])
  add.err <- y+epsi[,2]
  
  y[MS==1] = prop.err[MS==1]
  y[MS==2] = add.err[MS==2]
  
  return(list( y= y,poped.db =poped.db )) 
}

## ----echo=FALSE---------------------------------------------------------------
f_etaToParam <- function(x,a,bpop,b,bocc){
  parameters=c( 
    CL=bpop[1]*exp(b[1]),
    V=bpop[2]*exp(b[2]),
    E0=bpop[3]*exp(b[3]),
    EMAX=bpop[4],
    EC50=bpop[5]*exp(b[4]),
    DOSE=a[1]
  )
  return( parameters ) 
}

## -----------------------------------------------------------------------------
poped.db <- create.poped.database(
  
  # Model
  ff_fun=f_pkpdmodel,
  fError_fun=f_Err,
  fg_fun=f_etaToParam,
  sigma=diag(c(0.15,0.015)),
  bpop=c(CL=0.5,V=0.2,E0=1,EMAX=1,EC50=1),  
  d=c(CL=0.09,V=0.09,E0=0.04,EC50=0.09), 
  
  # Design
  groupsize=20,
  m=3,
  xt = c(0.33,0.66,0.9,5,0.1,1,2,5),
  model_switch=c(1,1,1,1,2,2,2,2),
  a=list(c(DOSE=0),c(DOSE=1),c(DOSE=2)),

  # Design space
  minxt=0,
  maxxt=5,
  bUseGrouped_xt=1,
  maxa=c(DOSE=10),
  mina=c(DOSE=0))

## ----simulate_multi-response_model--------------------------------------------
plot_model_prediction(
  poped.db,PI=TRUE,
  facet_scales="free",
  separate.groups=TRUE,
  model.names=c("PK","PD")) 

## ----eval=TRUE----------------------------------------------------------------
library(deSolve)

## -----------------------------------------------------------------------------
PK.2.comp.oral.ode <- function(Time, State, Pars){
  with(as.list(c(State, Pars)), {    
    dA1 <- -KA*A1 
    dA2 <- KA*A1 + A3* Q/V2 -A2*(CL/V1+Q/V1)
    dA3 <- A2* Q/V1-A3* Q/V2
    return(list(c(dA1, dA2, dA3)))
  })
}

## -----------------------------------------------------------------------------
ff.PK.2.comp.oral.md.ode <- function(model_switch, xt, parameters, poped.db){
  with(as.list(parameters),{
    
    # initial conditions of ODE system
    A_ini <- c(A1=0, A2=0, A3=0)

    #Set up time points to get ODE solutions
    times_xt <- drop(xt) # sample times
    times_start <- c(0) # add extra time for start of study
    times_dose = seq(from=0,to=max(times_xt),by=TAU) # dose times
    times <- unique(sort(c(times_start,times_xt,times_dose))) # combine it all
    
    # Dosing
    dose_dat <- data.frame(
      var = c("A1"), 
      time = times_dose,
      value = c(DOSE*Favail), 
      method = c("add")
    )
    
    out <- ode(A_ini, times, PK.2.comp.oral.ode, parameters,
               events = list(data = dose_dat))#atol=1e-13,rtol=1e-13)
    y = out[, "A2"]/V1
    y=y[match(times_xt,out[,"time"])]
    y=cbind(y)
    return(list(y=y,poped.db=poped.db))
  })
}


## ----echo=FALSE---------------------------------------------------------------
fg <- function(x,a,bpop,b,bocc){
  parameters=c( CL=bpop[1]*exp(b[1]),
                V1=bpop[2],
                KA=bpop[3]*exp(b[2]),
                Q=bpop[4],
                V2=bpop[5],
                Favail=bpop[6],
                DOSE=a[1],
                TAU=a[2])
  return( parameters ) 
}

## -----------------------------------------------------------------------------
poped.db <- create.poped.database(
  
  # Model
  ff_fun="ff.PK.2.comp.oral.md.ode",
  fError_fun="feps.add.prop",
  fg_fun="fg",
  sigma=c(prop=0.1^2,add=0.05^2),
  bpop=c(CL=10,V1=100,KA=1,Q= 3.0, V2= 40.0, Favail=1),
  d=c(CL=0.15^2,KA=0.25^2),
  notfixed_bpop=c(1,1,1,1,1,0),
  
  # Design
  groupsize=20,
  m=1,      #number of groups
  xt=c( 48,50,55,65,70,85,90,120),
  
  # Design space 
  minxt=0,
  maxxt=144,
  discrete_xt = list(0:144),
  a=c(DOSE=100,TAU=24),
  discrete_a = list(DOSE=seq(0,1000,by=100),TAU=8:24))

## ----simulate_ODE_model-------------------------------------------------------
plot_model_prediction(poped.db,model_num_points = 500)

## -----------------------------------------------------------------------------
library(Rcpp)
cppFunction(
  'List two_comp_oral_ode_Rcpp(double Time, NumericVector A, NumericVector Pars) {
     int n = A.size();
     NumericVector dA(n);
            
     double CL = Pars[0];
     double V1 = Pars[1];
     double KA = Pars[2];
     double Q  = Pars[3];
     double V2 = Pars[4];
            
     dA[0] = -KA*A[0];
     dA[1] = KA*A[0] - (CL/V1)*A[1] - Q/V1*A[1] + Q/V2*A[2];
     dA[2] = Q/V1*A[1] - Q/V2*A[2];
     return List::create(dA);
  }')

## -----------------------------------------------------------------------------
ff.PK.2.comp.oral.md.ode.Rcpp <- function(model_switch, xt, parameters, poped.db){
  with(as.list(parameters),{
    
    # initial conditions of ODE system
    A_ini <- c(A1=0, A2=0, A3=0)

    #Set up time points to get ODE solutions
    times_xt <- drop(xt) # sample times
    times_start <- c(0) # add extra time for start of study
    times_dose = seq(from=0,to=max(times_xt),by=TAU) # dose times
    times <- unique(sort(c(times_start,times_xt,times_dose))) # combine it all
    
    # Dosing
    dose_dat <- data.frame(
      var = c("A1"), 
      time = times_dose,
      value = c(DOSE*Favail), 
      method = c("add")
    )
    
    # Here "two_comp_oral_ode_Rcpp" is equivalent 
    # to the non-compiled version "PK.2.comp.oral.ode".
    out <- ode(A_ini, times, two_comp_oral_ode_Rcpp, parameters,
               events = list(data = dose_dat))#atol=1e-13,rtol=1e-13)
    y = out[, "A2"]/V1
    y=y[match(times_xt,out[,"time"])]
    y=cbind(y)
    return(list(y=y,poped.db=poped.db))
  })
}


## -----------------------------------------------------------------------------
poped.db.Rcpp <- create.poped.database(
  poped.db,
  ff_fun="ff.PK.2.comp.oral.md.ode.Rcpp")

## -----------------------------------------------------------------------------
tic(); eval <- evaluate_design(poped.db); toc()
tic(); eval <- evaluate_design(poped.db.Rcpp); toc()

## ----echo=FALSE, results="hide"-----------------------------------------------
cppFunction('List tmdd_qss_one_target_model_ode
            (double Time, NumericVector A, NumericVector Pars) {
            int n = A.size();
            NumericVector dA(n);
            
            double CL = Pars[0];
            double V1 = Pars[1];
            double Q  = Pars[2];
            double V2 = Pars[3];
            double FAVAIL = Pars[4];
            double KA = Pars[5];
            // double VMAX = Pars[6];
            // double KMSS = Pars[7];
            double R0 = Pars[8];
            double KSSS = Pars[9];
            double KDEG = Pars[10];
            double KINT = Pars[11];
            // double DOSE = Pars[12];
            // double SC_FLAG = Pars[13];
            
            double RTOT, CTOT, CFREE;
            RTOT = A[3];
            CTOT= A[1]/V1;
            CFREE = 0.5*((CTOT-RTOT-KSSS)+sqrt((CTOT-RTOT-KSSS)*(CTOT-RTOT-KSSS)+4*KSSS*CTOT));
            
            dA[0] = -KA*A[0];
            dA[1] = FAVAIL*KA*A[0]+(Q/V2)*A[2]-
            (CL/V1+Q/V1)*CFREE*V1-RTOT*KINT*CFREE*V1/(KSSS+CFREE);
            dA[2] = (Q/V1)*CFREE*V1 - (Q/V2)*A[2];
            dA[3] = R0*KDEG - KDEG*RTOT - (KINT-KDEG)*(RTOT*CFREE/(KSSS+CFREE));
            return List::create(dA);
            }')

## ----echo=FALSE, results="hide"-----------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  parameters=c( CL=bpop[1]*exp(b[1])  ,
                V1=bpop[2]*exp(b[2])	,
                Q=bpop[3]*exp(b[3])	,
                V2=bpop[4]*exp(b[4])	,
                FAVAIL=bpop[5]*exp(b[5])	,
                KA=bpop[6]*exp(b[6])	,                       
                VMAX=bpop[7]*exp(b[7])	,
                KMSS=bpop[8]*exp(b[8])	,
                R0=bpop[9]*exp(b[9])	,
                KSSS=bpop[10]*exp(b[10])	,
                KDEG=bpop[11]*exp(b[11])	,
                KINT=bpop[12]*exp(b[12])	,
                DOSE=a[1]	,
                SC_FLAG=a[2])   
  return(parameters) 
}

## -----------------------------------------------------------------------------
tmdd_qss_one_target_model_compiled <- function(model_switch,xt,parameters,poped.db){
  with(as.list(parameters),{
    y=xt
    
    #The initialization vector for the compartment
    A_ini <- c(A1=DOSE*SC_FLAG,
               A2=DOSE*(1-SC_FLAG),
               A3=0,
               A4=R0)
    
    #Set up time points for the ODE
    times_xt <- drop(xt)
    times <- sort(times_xt)
    times <- c(0,times) ## add extra time for start of integration
    
    # solve the ODE
    out <- ode(A_ini, times, tmdd_qss_one_target_model_ode, parameters)#,atol=1e-13,rtol=1e-13)
    
    
    # extract the time points of the observations
    out = out[match(times_xt,out[,"time"]),]
    
    # Match ODE output to measurements
    RTOT = out[,"A4"]
    CTOT = out[,"A2"]/V1
    CFREE = 0.5*((CTOT-RTOT-KSSS)+sqrt((CTOT-RTOT-KSSS)^2+4*KSSS*CTOT))
    COMPLEX=((RTOT*CFREE)/(KSSS+CFREE))
    RFREE= RTOT-COMPLEX
    
    y[model_switch==1]= RTOT[model_switch==1]
    y[model_switch==2] =CFREE[model_switch==2]
    #y[model_switch==3]=RFREE[model_switch==3]
    
    return(list( y=y,poped.db=poped.db))
  })
}


## ----echo=FALSE---------------------------------------------------------------
tmdd_qss_one_target_model_ruv <- function(model_switch,xt,parameters,epsi,poped.db){
  returnArgs <- do.call(poped.db$model$ff_pointer,list(model_switch,xt,parameters,poped.db))
  y <- returnArgs[[1]]
  poped.db <- returnArgs[[2]]
  
  y[model_switch==1] = log(y[model_switch==1])+epsi[,1]
  y[model_switch==2] = log(y[model_switch==2])+epsi[,2]
  
  return(list(y=y,poped.db=poped.db))
}


## -----------------------------------------------------------------------------
xt <- zeros(6,30)
study_1_xt <- matrix(rep(c(0.0417,0.25,0.5,1,3,7,14,21,28,35,42,49,56),8),nrow=4,byrow=TRUE)
study_2_xt <- matrix(rep(c(0.0417,1,1,7,14,21,28,56,63,70,77,84,91,98,105),4),nrow=2,byrow=TRUE)
xt[1:4,1:26] <- study_1_xt
xt[5:6,] <- study_2_xt

model_switch <- zeros(6,30)
model_switch[1:4,1:13] <- 1
model_switch[1:4,14:26] <- 2
model_switch[5:6,1:15] <- 1
model_switch[5:6,16:30] <- 2

G_xt <- zeros(6,30)
study_1_G_xt <- matrix(rep(c(1:13),8),nrow=4,byrow=TRUE)
study_2_G_xt <- matrix(rep(c(14:28),4),nrow=2,byrow=TRUE)
G_xt[1:4,1:26] <- study_1_G_xt
G_xt[5:6,] <- study_2_G_xt

## -----------------------------------------------------------------------------
poped.db.2 <- create.poped.database(
  
  # Model
  ff_fun=tmdd_qss_one_target_model_compiled,
  fError_fun=tmdd_qss_one_target_model_ruv,
  fg_fun=sfg,
  sigma=c(rtot_add=0.04,cfree_add=0.0225),
  bpop=c(CL=0.3,V1=3,Q=0.2,V2=3,FAVAIL=0.7,KA=0.5,VMAX=0,
         KMSS=0,R0=0.1,KSSS=0.015,KDEG=10,KINT=0.05),
  d=c(CL=0.09,V1=0.09,Q=0.04,V2=0.04,FAVAIL=0.04,
      KA=0.16,VMAX=0,KMSS=0,R0=0.09,KSSS=0.09,KDEG=0.04,
      KINT=0.04),
  notfixed_bpop=c( 1,1,1,1,1,1,0,0,1,1,1,1),
  notfixed_d=c( 1,1,1,1,1,1,0,0,1,1,1,1),
  
  # Design
  groupsize=rbind(6,6,6,6,100,100),
  m=6,      #number of groups
  xt=xt,
  model_switch=model_switch,
  ni=rbind(26,26,26,26,30,30),
  a=list(c(DOSE=100, SC_FLAG=0),
         c(DOSE=300, SC_FLAG=0),
         c(DOSE=600, SC_FLAG=0),
         c(DOSE=1000, SC_FLAG=1),
         c(DOSE=600, SC_FLAG=0),
         c(DOSE=1000, SC_FLAG=1)),
  
  # Design space
  bUseGrouped_xt=1,
  G_xt=G_xt,
  discrete_a = list(DOSE=seq(100,1000,by=100),
                    SC_FLAG=c(0,1)))


## ----simulate_different_dose_regimen------------------------------------------
plot_model_prediction(poped.db.2,facet_scales="free")

## ----results='hide'-----------------------------------------------------------
eval_2 <- evaluate_design(poped.db.2)
round(eval_2$rse) # in percent

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(round(eval_2$rse),col.names = c("RSE in %")) #%>%  
  #kableExtra::kable_styling("striped",full_width = F) 

## ----model--------------------------------------------------------------------
mod_1 <- function(model_switch,xt,parameters,poped.db){
  with(as.list(parameters),{
    y=xt
    
    CL=CL*(WT/70)^(WT_CL)
    V=V*(WT/70)^(WT_V)
    DOSE=1000*(WT/70)
    y = DOSE/V*exp(-CL/V*xt) 
    
    return(list( y= y,poped.db=poped.db))
  })
}

par_1 <- function(x,a,bpop,b,bocc){
  parameters=c( CL=bpop[1]*exp(b[1]),
                V=bpop[2]*exp(b[2]),
                WT_CL=bpop[3],
                WT_V=bpop[4],
                WT=a[1])
  return( parameters ) 
}

## ----design-------------------------------------------------------------------
poped_db <- 
  create.poped.database(
    ff_fun=mod_1,
    fg_fun=par_1,
    fError_fun=feps.add.prop,
    groupsize=50,
    m=1,
    sigma=c(prop=0.015,add=0.0015),
    notfixed_sigma = c(1,0),
    bpop=c(CL=3.8,V=20,WT_CL=0.75,WT_V=1), 
    d=c(CL=0.05,V=0.05), 
    xt=c( 1,2,4,6,8,24),
    minxt=0,
    maxxt=24,
    bUseGrouped_xt=1,
    a=c(WT=70)
  )

## -----------------------------------------------------------------------------
plot_model_prediction(poped_db)

## -----------------------------------------------------------------------------
evaluate_design(poped_db)

## -----------------------------------------------------------------------------
poped_db_2 <- 
  create.poped.database(
    ff_fun=mod_1,
    fg_fun=par_1,
    fError_fun=feps.add.prop,
    groupsize=1,
    m=50,
    sigma=c(prop=0.015,add=0.0015),
    notfixed_sigma = c(prop=1,add=0),
    bpop=c(CL=3.8,V=20,WT_CL=0.75,WT_V=1), 
    d=c(CL=0.05,V=0.05), 
    xt=c(1,2,4,6,8,24),
    minxt=0,
    maxxt=24,
    bUseGrouped_xt=1,
    a=as.list(rnorm(50, mean = 70, sd = 10))
  )


## -----------------------------------------------------------------------------
ev <- evaluate_design(poped_db_2) 
round(ev$ofv,1)

## ----results='hide'-----------------------------------------------------------
round(ev$rse)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(round(ev$rse),col.names = c("RSE in %")) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## ----cache=TRUE,results='hide'------------------------------------------------
nsim <- 30
rse_list <- c()
for(i in 1:nsim){
  poped_db_tmp <- 
    create.poped.database(
      ff_fun=mod_1,
      fg_fun=par_1,
      fError_fun=feps.add.prop,
      groupsize=1,
      m=50,
      sigma=c(prop=0.015,add=0.0015),
      notfixed_sigma = c(1,0),
      bpop=c(CL=3.8,V=20,WT_CL=0.75,WT_V=1), 
      d=c(CL=0.05,V=0.05), 
      xt=c( 1,2,4,6,8,24),
      minxt=0,
      maxxt=24,
      bUseGrouped_xt=1,
      a=as.list(rnorm(50,mean = 70,sd=10)))
  rse_tmp <- evaluate_design(poped_db_tmp)$rse
  rse_list <- rbind(rse_list,rse_tmp)
}
(rse_quant <- apply(rse_list,2,quantile))

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(as.data.frame(rse_quant),digits = 2)#,col.names = c("RSE in %")) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## -----------------------------------------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  parameters=c( CL_OCC_1=bpop[1]*exp(b[1]+bocc[1,1]),
                CL_OCC_2=bpop[1]*exp(b[1]+bocc[1,2]),
                V=bpop[2]*exp(b[2]),
                KA=bpop[3]*exp(b[3]),
                DOSE=a[1],
                TAU=a[2])
  return( parameters ) 
}

## -----------------------------------------------------------------------------
cppFunction(
  'List one_comp_oral_ode(double Time, NumericVector A, NumericVector Pars) {
   int n = A.size();
   NumericVector dA(n);
            
   double CL_OCC_1 = Pars[0];
   double CL_OCC_2 = Pars[1];
   double V = Pars[2];
   double KA = Pars[3];
   double TAU = Pars[4];
   double N,CL;
            
   N = floor(Time/TAU)+1;
   CL = CL_OCC_1;
   if(N>6) CL = CL_OCC_2;
   
   dA[0] = -KA*A[0];
   dA[1] = KA*A[0] - (CL/V)*A[1];
   return List::create(dA);
   }'
)

ff.ode.rcpp <- function(model_switch, xt, parameters, poped.db){
  with(as.list(parameters),{
    A_ini <- c(A1=0, A2=0)
    times_xt <- drop(xt) #xt[,,drop=T] 
    dose_times = seq(from=0,to=max(times_xt),by=TAU)
    eventdat <- data.frame(var = c("A1"), 
                           time = dose_times,
                           value = c(DOSE), method = c("add"))
    times <- sort(c(times_xt,dose_times))
    out <- ode(A_ini, times, one_comp_oral_ode, c(CL_OCC_1,CL_OCC_2,V,KA,TAU), 
               events = list(data = eventdat))#atol=1e-13,rtol=1e-13)
    y = out[, "A2"]/(V)
    y=y[match(times_xt,out[,"time"])]
    y=cbind(y)
    return(list(y=y,poped.db=poped.db))
  })
}


## -----------------------------------------------------------------------------
poped.db <- 
  create.poped.database(
    ff_fun=ff.ode.rcpp,
    fError_fun=feps.add.prop,
    fg_fun=sfg,
    bpop=c(CL=3.75,V=72.8,KA=0.25), 
    d=c(CL=0.25^2,V=0.09,KA=0.09), 
    sigma=c(prop=0.04,add=5e-6),
    notfixed_sigma=c(0,0),
    docc = matrix(c(0,0.09,0),nrow = 1),
    m=2,
    groupsize=20,
    xt=c( 1,2,8,240,245),
    minxt=c(0,0,0,240,240),
    maxxt=c(10,10,10,248,248),
    bUseGrouped_xt=1,
    a=list(c(DOSE=20,TAU=24),c(DOSE=40, TAU=24)),
    maxa=c(DOSE=200,TAU=24),
    mina=c(DOSE=0,TAU=24)
  )

## ----simulate_IOV_with_IIV----------------------------------------------------
library(ggplot2)
set.seed(123)
plot_model_prediction(
  poped.db, 
  PRED=F,IPRED=F, 
  separate.groups=T, 
  model_num_points = 300, 
  groupsize_sim = 1,
  IPRED.lines = T, 
  alpha.IPRED.lines=0.6,
  sample.times = F
) + geom_vline(xintercept = 24*6,color="red")

## ----results='hide'-----------------------------------------------------------
ev <- evaluate_design(poped.db)
round(ev$rse)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(round(ev$rse),col.names = c("RSE in %")) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## ----echo=FALSE, results="hide"-----------------------------------------------
ff <- function(model_switch,xt,parameters,poped.db){
  ##-- Model: One comp first order absorption
  with(as.list(parameters),{
    y=xt
    y=(DOSE*Favail*KA/(V*(KA-CL/V)))*(exp(-CL/V*xt)-exp(-KA*xt))
    return(list(y=y,poped.db=poped.db))
  })
}

sfg <- function(x,a,bpop,b,bocc){
  ## -- parameter definition function 
  parameters=c(CL=bpop[1]*exp(b[1]),
               V=bpop[2]*exp(b[2]),
               KA=bpop[3]*exp(b[3]),
               Favail=bpop[4],
               DOSE=a[1])
  return(parameters) 
}

feps <- function(model_switch,xt,parameters,epsi,poped.db){
  ## -- Residual Error function
  ## -- Proportional 
  returnArgs <- ff(model_switch,xt,parameters,poped.db) 
  y <- returnArgs[[1]]
  poped.db <- returnArgs[[2]]
  y = y*(1+epsi[,1])
  
  return(list(y=y,poped.db=poped.db)) 
}

## -- Define initial design  and design space
poped.db <- 
  create.poped.database(
    ff_file="ff",
    fg_file="sfg",
    fError_file="feps",
    bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
    notfixed_bpop=c(1,1,1,0),
    d=c(CL=0.07, V=0.02, KA=0.6), 
    sigma=c(prop=0.01),
    groupsize=32,
    xt=c( 0.5,1,2,6,24,36,72,120),
    minxt=0,
    maxxt=120,
    a=70
  )

## -----------------------------------------------------------------------------
poped.db_with <- 
  create.poped.database(
    ff_file="ff",
    fg_file="sfg",
    fError_file="feps",
    bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
    notfixed_bpop=c(1,1,1,0),
    d=c(CL=0.07, V=0.02, KA=0.6), 
    covd = c(.03,.1,.09),
    sigma=c(prop=0.01),
    groupsize=32,
    xt=c( 0.5,1,2,6,24,36,72,120),
    minxt=0,
    maxxt=120,
    a=70
  )

## -----------------------------------------------------------------------------
(IIV <- poped.db_with$parameters$param.pt.val$d)
cov2cor(IIV)

## ----simulate_with_cov_matrix-------------------------------------------------
library(ggplot2)
p1 <- plot_model_prediction(poped.db, PI=TRUE)+ylim(-0.5,12) 
p2 <- plot_model_prediction(poped.db_with,PI=TRUE) +ylim(-0.5,12)
gridExtra::grid.arrange(p1+ ggtitle("No covariance in BSV"), p2+ ggtitle("Covariance in BSV"), nrow = 1)

## -----------------------------------------------------------------------------
ev1 <- evaluate_design(poped.db)
ev2 <- evaluate_design(poped.db_with)

## ----results="hide"-----------------------------------------------------------
round(ev1$rse)
round(ev2$rse)

## ----echo=FALSE,message=FALSE-------------------------------------------------
tb1 <- tibble::tibble(" "=names(ev1$rse),
         "Diagonal BSV"=ev1$rse)

tb2 <- tibble::tibble(" "=names(ev2$rse),
         "Covariance in BSV"=ev2$rse)

tb_final <- dplyr::right_join(tb1,tb2,by=" ")

knitr::kable(tb_final,digits = 0) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## ----results='hide'-----------------------------------------------------------
ev1 <- evaluate_design(poped.db, fim.calc.type=0)
ev2 <-evaluate_design(poped.db_with, fim.calc.type=0)

round(ev1$rse,1)
round(ev2$rse,1)

## ----echo=FALSE,message=FALSE-------------------------------------------------
tb1 <- tibble::tibble(" "=names(ev1$rse),
         "Diagonal BSV"=ev1$rse)

tb2 <- tibble::tibble(" "=names(ev2$rse),
         "Covariance in BSV"=ev2$rse)

tb_final <- dplyr::right_join(tb1,tb2,by=" ")

knitr::kable(tb_final,digits = 0) #%>%  
  #kableExtra::kable_styling("striped",full_width = FALSE) 

## -----------------------------------------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  parameters=c( 
    V=bpop[1]*exp(b[1]),
    KA=bpop[2]*exp(b[2]),
    CL=bpop[3]*exp(b[3])*bpop[5]^a[3], # add covariate for pediatrics
    Favail=bpop[4],
    isPediatric = a[3],
    DOSE=a[1],
    TAU=a[2])
  return( parameters ) 
}

## -----------------------------------------------------------------------------
poped.db <- 
  create.poped.database(
    ff_fun=ff.PK.1.comp.oral.md.CL,
    fg_fun=sfg,
    fError_fun=feps.add.prop,
    bpop=c(V=72.8,KA=0.25,CL=3.75,Favail=0.9,pedCL=0.8), 
    notfixed_bpop=c(1,1,1,0,1),
    d=c(V=0.09,KA=0.09,CL=0.25^2), 
    sigma=c(0.04,5e-6),
    notfixed_sigma=c(0,0),
    m=2,
    groupsize=20,
    xt=c( 1,8,10,240,245),
    bUseGrouped_xt=1,
    a=list(c(DOSE=20,TAU=24,isPediatric = 0),
           c(DOSE=40, TAU=24,isPediatric = 0))
  )

## ----simulate_adult-----------------------------------------------------------
plot_model_prediction(poped.db, model_num_points = 300)


## -----------------------------------------------------------------------------
(outAdult = evaluate_design(poped.db))

## -----------------------------------------------------------------------------
evaluate_design(create.poped.database(poped.db, notfixed_bpop=c(1,1,1,0,0)))

## -----------------------------------------------------------------------------
poped.db.ped <- 
  create.poped.database(
    ff_fun=ff.PK.1.comp.oral.md.CL,
    fg_fun=sfg,
    fError_fun=feps.add.prop,
    bpop=c(V=72.8,KA=0.25,CL=3.75,Favail=0.9,pedCL=0.8), 
    notfixed_bpop=c(1,1,1,0,1),
    d=c(V=0.09,KA=0.09,CL=0.25^2), 
    sigma=c(0.04,5e-6),
    notfixed_sigma=c(0,0),
    m=1,
    groupsize=6,
    xt=c( 1,2,6,240),
    bUseGrouped_xt=1,
    a=list(c(DOSE=40,TAU=24,isPediatric = 1))
  )

## ----simulate_pediatrics------------------------------------------------------
plot_model_prediction(poped.db.ped, model_num_points = 300)

## -----------------------------------------------------------------------------
evaluate_design(poped.db.ped)


## -----------------------------------------------------------------------------
poped.db.all <- create.poped.database(
  poped.db.ped,
  prior_fim = outAdult$fim
)

(out.all <- evaluate_design(poped.db.all))

## -----------------------------------------------------------------------------
evaluate_power(poped.db.all, bpop_idx=5, h0=1, out=out.all)

## ----echo=FALSE, results="hide"-----------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  ## -- parameter definition function 
  parameters=c(
    CL=bpop[1]*exp(b[1]),
    V=bpop[2]*exp(b[2]),
    KA=bpop[3]*exp(b[3]),
    Favail=bpop[4],
    DOSE=a[1])
  return(parameters) 
}

ff <- function(model_switch,xt,parameters,poped.db){
  ##-- Model: One comp first order absorption
  with(as.list(parameters),{
    y=xt
    y=(DOSE*Favail*KA/(V*(KA-CL/V)))*(exp(-CL/V*xt)-exp(-KA*xt))
    return(list(y=y,poped.db=poped.db))
  })
}

## -----------------------------------------------------------------------------
bpop_vals <- c(CL=0.15, V=8, KA=1.0, Favail=1)
bpop_vals_ed <- 
  cbind(ones(length(bpop_vals),1)*4, # log-normal distribution
        bpop_vals,
        ones(length(bpop_vals),1)*(bpop_vals*0.1)^2) # 10% of bpop value
bpop_vals_ed["Favail",] <- c(0,1,0)
bpop_vals_ed

## -----------------------------------------------------------------------------
poped.db <- 
  create.poped.database(
    ff_fun=ff,
    fg_fun=sfg,
    fError_fun=feps.add.prop,
    bpop=bpop_vals_ed, 
    notfixed_bpop=c(1,1,1,0),
    d=c(CL=0.07, V=0.02, KA=0.6), 
    sigma=c(0.01,0.25),
    groupsize=32,
    xt=c( 0.5,1,2,6,24,36,72,120),
    minxt=0,
    maxxt=120,
    a=70,
    mina=0,
    maxa=100,
    ED_samp_size=20)

## -----------------------------------------------------------------------------
tic();evaluate_design(poped.db,d_switch=FALSE,ED_samp_size=20); toc()

## -----------------------------------------------------------------------------
tic();evaluate_design(poped.db,d_switch=FALSE,ED_samp_size=20); toc()

## ----echo=FALSE---------------------------------------------------------------
sfg <- function(x,a,bpop,b,bocc){
  ## -- parameter definition function 
  parameters=c(CL=bpop[1]*exp(b[1]),
               V=bpop[2]*exp(b[2]),
               KA=bpop[3]*exp(b[3]),
               Favail=bpop[4],
               DOSE=a[1])
  return(parameters) 
}

ff <- function(model_switch,xt,parameters,poped.db){
  ##-- Model: One comp first order absorption
  with(as.list(parameters),{
    y=xt
    y=(DOSE*Favail*KA/(V*(KA-CL/V)))*(exp(-CL/V*xt)-exp(-KA*xt))
    return(list(y=y,poped.db=poped.db))
  })
}

## -----------------------------------------------------------------------------
poped.db <- 
  create.poped.database(
    ff_fun=ff,
    fg_fun=sfg,
    fError_fun=feps.add.prop,
    bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
    notfixed_bpop=c(1,1,1,0),
    d=c(CL=0.07, V=0.02, KA=0.6), 
    sigma=c(0.01,0.25),
    groupsize=32,
    xt=c( 0.5,1,2,6,24,36,72,120),
    minxt=0,
    maxxt=120,
    a=70,
    mina=0,
    maxa=100,
    ds_index=c(0,0,0,1,1,1,1,1), # size is number_of_non_fixed_parameters
    ofv_calc_type=6) # Ds OFV calculation

## -----------------------------------------------------------------------------
evaluate_design(poped.db)

## ----echo=FALSE, results="hide"-----------------------------------------------

sfg <- function(x,a,bpop,b,bocc){
  ## -- parameter definition function 
  parameters=c(KA=bpop[1]*exp(b[1]),
               K=bpop[2]*exp(b[2]),
               V=bpop[3]*exp(b[3]),
               DOSE=a[1])
  return(parameters) 
}

ff <- function(model_switch,xt,parameters,poped.db){
  ##-- Model: One comp first order absorption
  with(as.list(parameters),{
    y<-(DOSE/V*KA/(KA-K)*(exp(-K*xt)-exp(-KA*xt)))
    return(list(y=y,poped.db=poped.db))
  })
}

## -- Residual unexplained variablity (RUV) function
## -- Additive + Proportional  
feps <- function(model_switch,xt,parameters,epsi,poped.db){
  returnArgs <- do.call(poped.db$model$ff_pointer,
                        list(model_switch,xt,parameters,poped.db)) 
  f <- returnArgs[[1]]
  y = f + (0.5 + 0.15*f)*epsi[,1]
  
  return(list( y= y,poped.db =poped.db )) 
}
## -- Define initial design  and design space
poped.db <- create.poped.database(
  ff_fun=ff,
  fg_fun=sfg,
  fError_fun =feps,
  bpop=c(KA=2, K=0.25, V=15), 
  d=c(KA=1, V=0.25,0.1), 
  sigma=c(1),
  notfixed_sigma = c(0),
  groupsize=1,
  xt=c( 1,3,8),
  minxt=0,
  maxxt=10,
  a=100)

plot_model_prediction(poped.db)


## -----------------------------------------------------------------------------
shrinkage(poped.db)

