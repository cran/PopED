% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blockheader.R
\name{blockheader}
\alias{blockheader}
\title{Header function for optimization routines}
\usage{
blockheader(
  poped.db,
  name = "Default",
  iter = NULL,
  e_flag = !(poped.db$settings$d_switch),
  opt_xt = poped.db$settings$optsw[2],
  opt_a = poped.db$settings$optsw[4],
  opt_x = poped.db$settings$optsw[3],
  opt_samps = poped.db$settings$optsw[1],
  opt_inds = poped.db$settings$optsw[5],
  fmf = 0,
  dmf = 0,
  bpop = NULL,
  d = NULL,
  docc = NULL,
  sigma = NULL,
  name_header = poped.db$settings$strOutputFileName,
  file_path = poped.db$settings$strOutputFilePath,
  out_file = NULL,
  compute_inv = TRUE,
  trflag = TRUE,
  header_flag = TRUE,
  ...
)
}
\arguments{
\item{poped.db}{A PopED database.}

\item{name}{The name used for the output file. Combined with \code{name_header} and \code{iter}. 
If \code{""} then output is to the screen.}

\item{iter}{The last number in the name printed to the output file, combined with \code{name}.}

\item{e_flag}{Should output be with uncertainty around parameters?}

\item{opt_xt}{Should the sample times be optimized?}

\item{opt_a}{Should the continuous design variables be optimized?}

\item{opt_x}{Should the discrete design variables be optimized?}

\item{opt_samps}{Are the number of sample times per group being optimized?}

\item{opt_inds}{Are the number of individuals per group being optimized?}

\item{fmf}{The initial value of the FIM. If set to zero then it is computed.}

\item{dmf}{The initial OFV. If set to zero then it is computed.}

\item{bpop}{Matrix defining the fixed effects, per row (row number = parameter_number) we should have:
\itemize{
\item column 1 the type of the distribution for E-family designs (0 = Fixed, 1 = Normal, 2 = Uniform,
 3 = User Defined Distribution, 4 = lognormal and 5 = truncated normal)
\item column 2  defines the mean.
\item column 3 defines the variance of the distribution (or length of uniform distribution).
}
Can also just supply the parameter values as a vector \code{c()} if no uncertainty around the 
parameter value is to be used. The parameter order of  'bpop' is defined in the 'fg_fun' or 'fg_file'. If you use named 
arguments in 'bpop' then the order of this vector can be rearranged to match the 'fg_fun' or 'fg_file'. 
See `reorder_parameter_vectors`.}

\item{d}{Matrix defining the diagonals of the IIV (same logic as for the fixed effects 
matrix bpop to define uncertainty). One can also just supply the parameter values as a \code{c()}. 
The parameter order of 'd' is defined in the 'fg_fun' or 'fg_file'. If you use named 
arguments in 'd' then the order of this vector can be rearranged to match the 'fg_fun' or 'fg_file'. 
See `reorder_parameter_vectors`.}

\item{docc}{Matrix defining the IOV, the IOV variances and the IOV distribution as for d and bpop.}

\item{sigma}{Matrix defining the variances can covariances of the residual variability terms of the model.
can also just supply the diagonal parameter values (variances) as a \code{c()}.}

\item{name_header}{The initial portion of the file name.}

\item{file_path}{The path to where the file should be created.}

\item{out_file}{Which file should the output be directed to?  A string, a file handle using 
\code{\link{file}} or \code{""} will output to the screen.}

\item{compute_inv}{should the inverse of the FIM be used to compute expected RSE values?  Often not needed
except for diagnostic purposes.}

\item{trflag}{Should the optimization be output to the screen and to a file?}

\item{header_flag}{Should the header text be printed out?}

\item{...}{Additional arguments passed to further functions.}
}
\value{
fn A file handle (or \code{''} if \code{name=''})
}
\description{
Create some output to the screen and a text file that summarizes the problem you are tying to solve.
}
\examples{
library(PopED)

############# START #################
## Create PopED database
## (warfarin model for optimization)
#####################################

## Warfarin example from software comparison in:
## Nyberg et al., "Methods and software tools for design evaluation 
##   for population pharmacokinetics-pharmacodynamics studies", 
##   Br. J. Clin. Pharm., 2014. 

## Optimization using an additive + proportional reidual error  
## to avoid sample times at very low concentrations (time 0 or very late samples).

## find the parameters that are needed to define from the structural model
ff.PK.1.comp.oral.sd.CL

## -- parameter definition function 
## -- names match parameters in function ff
sfg <- function(x,a,bpop,b,bocc){
  parameters=c(CL=bpop[1]*exp(b[1]),
               V=bpop[2]*exp(b[2]),
               KA=bpop[3]*exp(b[3]),
               Favail=bpop[4],
               DOSE=a[1])
  return(parameters) 
}

## -- Define initial design  and design space
poped.db <- create.poped.database(ff_fun=ff.PK.1.comp.oral.sd.CL,
                                  fg_fun=sfg,
                                  fError_fun=feps.add.prop,
                                  bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
                                  notfixed_bpop=c(1,1,1,0),
                                  d=c(CL=0.07, V=0.02, KA=0.6), 
                                  sigma=c(prop=0.01,add=0.25),
                                  groupsize=32,
                                  xt=c( 0.5,1,2,6,24,36,72,120),
                                  minxt=0.01,
                                  maxxt=120,
                                  a=c(DOSE=70),
                                  mina=c(DOSE=0.01),
                                  maxa=c(DOSE=100))

############# END ###################
## Create PopED database
## (warfarin model for optimization)
#####################################


FIM <- evaluate.fim(poped.db) 
dmf <- det(FIM)

blockheader(poped.db,name="")

blockheader(name="",iter=1,poped.db)


blockheader(name='',
              iter=1,
              poped.db,
              e_flag=FALSE,
              opt_xt=TRUE,
              opt_a=TRUE,opt_x=poped.db$settings$optsw[4],
              opt_samps=poped.db$settings$optsw[1],opt_inds=poped.db$settings$optsw[5],
              fmf=FIM,dmf=dmf,
              bpop=poped.db$parameters$param.pt.val$bpop,
              d=poped.db$parameters$param.pt.val$d,
              docc=poped.db$parameters$docc,sigma=poped.db$parameters$param.pt.val$sigma)



blockheader(name='',
              iter=1,
              poped.db,
              e_flag=TRUE,
              opt_xt=TRUE,
              opt_a=TRUE,opt_x=poped.db$settings$optsw[4],
              opt_samps=poped.db$settings$optsw[1],opt_inds=poped.db$settings$optsw[5],
              fmf=FIM,dmf=dmf,
              bpop=poped.db$parameters$param.pt.val$bpop,
              d=poped.db$parameters$param.pt.val$d,
              docc=poped.db$parameters$docc,sigma=poped.db$parameters$param.pt.val$sigma)
  
  
poped.db.1 <- create.poped.database(ff_fun=ff.PK.1.comp.oral.sd.CL,
                                  fg_fun=sfg,
                                  fError_fun=feps.add.prop,
                                  bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
                                  notfixed_bpop=c(1,1,1,0),
                                  d=c(CL=0.07, V=0.02, KA=0.6), 
                                  sigma=c(0.01,0.25),
                                  groupsize=32,
                                  xt=rbind(c( 0.5,1,2,6,24,36,72,120),
                                           c( 0.5,1.1,2,6,24,36,72,120)),
                                  minxt=rbind(c(0,1,1.5,3,20,30,70,118),
                                              c(0.1,1.1,1.6,3.1,20.1,30.1,70.1,118.1)),
                                  maxxt=c(12,13,14,15,26,44,78,120),
                                  a=70,
                                  mina=0,
                                  maxa=100)


blockheader(poped.db.1,name="",trflag=2,opt_xt=TRUE)


}
\seealso{
Other Helper: 
\code{\link{blockexp}()},
\code{\link{blockfinal}()},
\code{\link{blockopt}()}
}
\concept{Helper}
\keyword{internal}
