% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create.poped.database.R
\name{create.poped.database}
\alias{create.poped.database}
\title{Create a PopED database}
\usage{
create.poped.database(
  popedInput = list(),
  ff_file = NULL,
  ff_fun = poped.choose(popedInput$model$ff_pointer, NULL),
  fg_file = NULL,
  fg_fun = poped.choose(popedInput$model$fg_pointer, NULL),
  fError_file = NULL,
  fError_fun = poped.choose(popedInput$model$ferror_pointer, NULL),
  optsw = poped.choose(popedInput$settings$optsw, cbind(0, 0, 0, 0, 0)),
  xt = poped.choose(popedInput$design[["xt"]], stop("'xt' needs to be defined")),
  m = poped.choose(popedInput$design[["m"]], NULL),
  x = poped.choose(popedInput$design[["x"]], NULL),
  nx = poped.choose(popedInput$design$nx, NULL),
  a = poped.choose(popedInput$design[["a"]], NULL),
  groupsize = poped.choose(popedInput$design$groupsize,
    stop("'groupsize' needs to be defined")),
  ni = poped.choose(popedInput$design$ni, NULL),
  model_switch = poped.choose(popedInput$design$model_switch, NULL),
  maxni = poped.choose(popedInput$design_space$maxni, NULL),
  minni = poped.choose(popedInput$design_space$minni, NULL),
  maxtotni = poped.choose(popedInput$design_space$maxtotni, NULL),
  mintotni = poped.choose(popedInput$design_space$mintotni, NULL),
  maxgroupsize = poped.choose(popedInput$design_space$maxgroupsize, NULL),
  mingroupsize = poped.choose(popedInput$design_space$mingroupsize, NULL),
  maxtotgroupsize = poped.choose(popedInput$design_space$maxtotgroupsize, NULL),
  mintotgroupsize = poped.choose(popedInput$design_space$mintotgroupsize, NULL),
  maxxt = poped.choose(popedInput$design_space$maxxt, NULL),
  minxt = poped.choose(popedInput$design_space$minxt, NULL),
  discrete_xt = poped.choose(popedInput$design_space$xt_space, NULL),
  discrete_x = poped.choose(popedInput$design_space$discrete_x, NULL),
  maxa = poped.choose(popedInput$design_space$maxa, NULL),
  mina = poped.choose(popedInput$design_space$mina, NULL),
  discrete_a = poped.choose(popedInput$design_space$a_space, NULL),
  bUseGrouped_xt = poped.choose(popedInput$design_space$bUseGrouped_xt, FALSE),
  G_xt = poped.choose(popedInput$design_space$G_xt, NULL),
  bUseGrouped_a = poped.choose(popedInput$design_space$bUseGrouped_a, FALSE),
  G_a = poped.choose(popedInput$design_space$G_a, NULL),
  bUseGrouped_x = poped.choose(popedInput$design_space$bUseGrouped_x, FALSE),
  G_x = poped.choose(popedInput$design_space[["G_x"]], NULL),
  iFIMCalculationType = poped.choose(popedInput$settings$iFIMCalculationType, 1),
  iApproximationMethod = poped.choose(popedInput$settings$iApproximationMethod, 0),
  iFOCENumInd = poped.choose(popedInput$settings$iFOCENumInd, 1000),
  prior_fim = poped.choose(popedInput$settings$prior_fim, matrix(0, 0, 1)),
  strAutoCorrelationFile = poped.choose(popedInput$model$auto_pointer, ""),
  d_switch = poped.choose(popedInput$settings$d_switch, 1),
  ofv_calc_type = poped.choose(popedInput$settings$ofv_calc_type, 4),
  ds_index = popedInput$parameters$ds_index,
  strEDPenaltyFile = poped.choose(popedInput$settings$strEDPenaltyFile, ""),
  ofv_fun = poped.choose(popedInput$settings$ofv_fun, NULL),
  iEDCalculationType = poped.choose(popedInput$settings$iEDCalculationType, 0),
  ED_samp_size = poped.choose(popedInput$settings$ED_samp_size, 45),
  bLHS = poped.choose(popedInput$settings$bLHS, 1),
  strUserDistributionFile = poped.choose(popedInput$model$user_distribution_pointer, ""),
  nbpop = popedInput$parameters$nbpop,
  NumRanEff = popedInput$parameters$NumRanEff,
  NumDocc = popedInput$parameters$NumDocc,
  NumOcc = popedInput$parameters$NumOcc,
  bpop = poped.choose(popedInput$parameters$bpop, stop("bpop must be defined")),
  d = poped.choose(popedInput$parameters$d, NULL),
  covd = popedInput$parameters$covd,
  sigma = popedInput$parameters$sigma,
  docc = poped.choose(popedInput$parameters$docc, matrix(0, 0, 3)),
  covdocc = poped.choose(popedInput$parameters$covdocc, zeros(1, length(docc[, 2, drop =
    F]) * (length(docc[, 2, drop = F]) - 1)/2)),
  notfixed_bpop = popedInput$parameters$notfixed_bpop,
  notfixed_d = popedInput$parameters$notfixed_d,
  notfixed_covd = popedInput$parameters$notfixed_covd,
  notfixed_docc = popedInput$parameters$notfixed_docc,
  notfixed_covdocc = poped.choose(popedInput$parameters$notfixed_covdocc, zeros(1,
    length(covdocc))),
  notfixed_sigma = poped.choose(popedInput$parameters$notfixed_sigma, t(rep(1,
    size(sigma, 2)))),
  notfixed_covsigma = poped.choose(popedInput$parameters$notfixed_covsigma, zeros(1,
    length(notfixed_sigma) * (length(notfixed_sigma) - 1)/2)),
  reorder_parameter_vectors = FALSE,
  bUseRandomSearch = poped.choose(popedInput$settings$bUseRandomSearch, TRUE),
  bUseStochasticGradient = poped.choose(popedInput$settings$bUseStochasticGradient, TRUE),
  bUseLineSearch = poped.choose(popedInput$settings$bUseLineSearch, TRUE),
  bUseExchangeAlgorithm = poped.choose(popedInput$settings$bUseExchangeAlgorithm, FALSE),
  bUseBFGSMinimizer = poped.choose(popedInput$settings$bUseBFGSMinimizer, FALSE),
  EACriteria = poped.choose(popedInput$settings$EACriteria, 1),
  strRunFile = poped.choose(popedInput$settings$run_file_pointer, ""),
  poped_version = poped.choose(popedInput$settings$poped_version,
    packageVersion("PopED")),
  modtit = poped.choose(popedInput$settings$modtit, "PopED model"),
  output_file = poped.choose(popedInput$settings$output_file, paste("PopED_output",
    "_summary", sep = "")),
  output_function_file = poped.choose(popedInput$settings$output_function_file,
    paste("PopED", "_output_", sep = "")),
  strIterationFileName = poped.choose(popedInput$settings$strIterationFileName,
    paste("PopED", "_current.R", sep = "")),
  user_data = poped.choose(popedInput$settings$user_data, cell(0, 0)),
  ourzero = poped.choose(popedInput$settings$ourzero, 1e-05),
  dSeed = poped.choose(popedInput$settings$dSeed, NULL),
  line_opta = poped.choose(popedInput$settings$line_opta, NULL),
  line_optx = poped.choose(popedInput$settings$line_optx, NULL),
  bShowGraphs = poped.choose(popedInput$settings$bShowGraphs, FALSE),
  use_logfile = poped.choose(popedInput$settings$use_logfile, FALSE),
  m1_switch = poped.choose(popedInput$settings$m1_switch, 1),
  m2_switch = poped.choose(popedInput$settings$m2_switch, 1),
  hle_switch = poped.choose(popedInput$settings$hle_switch, 1),
  gradff_switch = poped.choose(popedInput$settings$gradff_switch, 1),
  gradfg_switch = poped.choose(popedInput$settings$gradfg_switch, 1),
  grad_all_switch = poped.choose(popedInput$settings$grad_all_switch, 1),
  rsit_output = poped.choose(popedInput$settings$rsit_output, 5),
  sgit_output = poped.choose(popedInput$settings$sgit_output, 1),
  hm1 = poped.choose(popedInput$settings[["hm1"]], 1e-05),
  hlf = poped.choose(popedInput$settings[["hlf"]], 1e-05),
  hlg = poped.choose(popedInput$settings[["hlg"]], 1e-05),
  hm2 = poped.choose(popedInput$settings[["hm2"]], 1e-05),
  hgd = poped.choose(popedInput$settings[["hgd"]], 1e-05),
  hle = poped.choose(popedInput$settings[["hle"]], 1e-05),
  AbsTol = poped.choose(popedInput$settings$AbsTol, 1e-06),
  RelTol = poped.choose(popedInput$settings$RelTol, 1e-06),
  iDiffSolverMethod = poped.choose(popedInput$settings$iDiffSolverMethod, NULL),
  bUseMemorySolver = poped.choose(popedInput$settings$bUseMemorySolver, FALSE),
  rsit = poped.choose(popedInput$settings[["rsit"]], 300),
  sgit = poped.choose(popedInput$settings[["sgit"]], 150),
  intrsit = poped.choose(popedInput$settings$intrsit, 250),
  intsgit = poped.choose(popedInput$settings$intsgit, 50),
  maxrsnullit = poped.choose(popedInput$settings$maxrsnullit, 50),
  convergence_eps = poped.choose(popedInput$settings$convergence_eps, 1e-08),
  rslxt = poped.choose(popedInput$settings$rslxt, 10),
  rsla = poped.choose(popedInput$settings$rsla, 10),
  cfaxt = poped.choose(popedInput$settings$cfaxt, 0.001),
  cfaa = poped.choose(popedInput$settings$cfaa, 0.001),
  bGreedyGroupOpt = poped.choose(popedInput$settings$bGreedyGroupOpt, FALSE),
  EAStepSize = poped.choose(popedInput$settings$EAStepSize, 0.01),
  EANumPoints = poped.choose(popedInput$settings$EANumPoints, FALSE),
  EAConvergenceCriteria = poped.choose(popedInput$settings$EAConvergenceCriteria, 1e-20),
  bEANoReplicates = poped.choose(popedInput$settings$bEANoReplicates, FALSE),
  BFGSConvergenceCriteriaMinStep = NULL,
  BFGSProjectedGradientTol = poped.choose(popedInput$settings$BFGSProjectedGradientTol,
    1e-04),
  BFGSTolerancef = poped.choose(popedInput$settings$BFGSTolerancef, 0.001),
  BFGSToleranceg = poped.choose(popedInput$settings$BFGSToleranceg, 0.9),
  BFGSTolerancex = poped.choose(popedInput$settings$BFGSTolerancex, 0.1),
  ED_diff_it = poped.choose(popedInput$settings$ED_diff_it, 30),
  ED_diff_percent = poped.choose(popedInput$settings$ED_diff_percent, 10),
  line_search_it = poped.choose(popedInput$settings$ls_step_size, 50),
  Doptim_iter = poped.choose(popedInput$settings$iNumSearchIterationsIfNotLineSearch, 1),
  iCompileOption = poped.choose(popedInput$settings$parallel$iCompileOption, -1),
  iUseParallelMethod = poped.choose(popedInput$settings$parallel$iUseParallelMethod, 1),
  MCC_Dep = NULL,
  strExecuteName = poped.choose(popedInput$settings$parallel$strExecuteName,
    "calc_fim.exe"),
  iNumProcesses = poped.choose(popedInput$settings$parallel$iNumProcesses, 2),
  iNumChunkDesignEvals = poped.choose(popedInput$settings$parallel$iNumChunkDesignEvals,
    -2),
  Mat_Out_Pre = poped.choose(popedInput$settings$parallel$strMatFileOutputPrefix,
    "parallel_output"),
  strExtraRunOptions = poped.choose(popedInput$settings$parallel$strExtraRunOptions, ""),
  dPollResultTime = poped.choose(popedInput$settings$parallel$dPollResultTime, 0.1),
  strFunctionInputName = poped.choose(popedInput$settings$parallel$strFunctionInputName,
    "function_input"),
  bParallelRS = poped.choose(popedInput$settings$parallel$bParallelRS, FALSE),
  bParallelSG = poped.choose(popedInput$settings$parallel$bParallelSG, FALSE),
  bParallelMFEA = poped.choose(popedInput$settings$parallel$bParallelMFEA, FALSE),
  bParallelLS = poped.choose(popedInput$settings$parallel$bParallelLS, FALSE)
)
}
\arguments{
\item{popedInput}{A PopED database file or an empty list \code{list()}.  List elements should match the values seen in 
the Usage section (the defaults to function arguments).}

\item{ff_file}{\itemize{
\item \bold{******START OF MODEL DEFINITION OPTIONS**********}
}
A string giving the function name or filename and path of the structural model. 
The filename and the function name must be the same if giving a filename. 
e.g. \code{"ff.PK.1.comp.oral.md.KE"}}

\item{ff_fun}{Function describing the structural model. e.g. \code{ff.PK.1.comp.oral.md.KE}.}

\item{fg_file}{A string giving the function name or filename and path of the 
parameter model. 
The filename and the function name must be the same if giving a filename. 
e.g. \code{"parameter.model"}}

\item{fg_fun}{Function describing the parameter model. e.g. \code{parameter.model}.}

\item{fError_file}{A string giving the function name or filename and path of the 
residual error model. 
The filename and the function name must be the same if giving a filename. 
e.g. \code{"feps.prop"}.}

\item{fError_fun}{Function describing the residual error model. e.g. \code{feps.prop}.}

\item{optsw}{\itemize{
\item \bold{******WHAT TO OPTIMIZE**********}}
 Row vector of optimization tasks (1=TRUE,0=FALSE) in the following order: 
(Samples per subject, Sampling schedule, Discrete design variable, Continuous design variable, Number of id per group). 
All elements set to zero => only calculate the FIM with current design}

\item{xt}{\itemize{
\item \bold{******START OF INITIAL DESIGN OPTIONS**********}}
 Matrix defining the initial sampling schedule. 
 Each row is a group/individual.
 If only one vector is supplied, e.g. \code{c(1,2,3,4)}, then all groups will 
have the same initial design.}

\item{m}{Number of groups in the study.  Each individual in a group will have the same design.}

\item{x}{A matrix defining the initial discrete values for the model 
Each row is a group/individual.}

\item{nx}{Number of discrete design variables.}

\item{a}{Matrix defining the initial continuous covariate values. 
n_rows=number of groups, n_cols=number of covariates.
If the number of rows is one and the number of groups > 1 then all groups are assigned the 
same values.}

\item{groupsize}{Vector defining the size of the different groups (num individuals in each group).
If only one number then the number will be the same in every group.}

\item{ni}{Vector defining the number of samples for each group.}

\item{model_switch}{Matrix defining which response a certain sampling time belongs to.}

\item{maxni}{\itemize{
\item \bold{******START OF DESIGN SPACE OPTIONS**********}}
Max number of samples per group/individual}

\item{minni}{Min number of samples per group/individual}

\item{maxtotni}{Number defining the maximum number of samples allowed in the experiment.}

\item{mintotni}{Number defining the minimum number of samples allowed in the experiment.}

\item{maxgroupsize}{Vector defining the max size of the different groups (max number of individuals in each group)}

\item{mingroupsize}{Vector defining the min size of the different groups (min num individuals in each group) --}

\item{maxtotgroupsize}{The total maximal groupsize over all groups}

\item{mintotgroupsize}{The total minimal groupsize over all groups}

\item{maxxt}{Matrix or single value defining the maximum value for each xt sample.  If a single value is 
supplied then all xt values are given the same maximum value.}

\item{minxt}{Matrix or single value defining the minimum value for each xt sample.  If a single value is 
supplied then all xt values are given the same minimum value}

\item{discrete_xt}{Cell array \code{\link{cell}} defining the discrete variables allowed for each xt value.
 Can also be a list of values \code{list(1:10)} (same values allowed for all xt), or a list of lists 
\code{list(1:10, 2:23, 4:6)} (one for each value in xt). See examples in \code{\link{create_design_space}}.}

\item{discrete_x}{Cell array defining the discrete variables for each x value. 
See examples in \code{\link{create_design_space}}.}

\item{maxa}{Vector defining the max value for each covariate. If a single value is supplied then
all a values are given the same max value}

\item{mina}{Vector defining the min value for each covariate. If a single value is supplied then
all a values are given the same max value}

\item{discrete_a}{Cell array \code{\link{cell}} defining the discrete variables allowed for each a value.
 Can also be a list of values \code{list(1:10)} (same values allowed for all a), or a list of lists 
\code{list(1:10, 2:23, 4:6)} (one for each value in a). See examples in \code{\link{create_design_space}}.}

\item{bUseGrouped_xt}{Use grouped time points (1=TRUE, 0=FALSE).}

\item{G_xt}{Matrix defining the grouping of sample points. Matching integers mean that the points are matched.}

\item{bUseGrouped_a}{Use grouped covariates (1=TRUE, 0=FALSE)}

\item{G_a}{Matrix defining the grouping of covariates. Matching integers mean that the points are matched.}

\item{bUseGrouped_x}{Use grouped discrete design variables (1=TRUE, 0=FALSE).}

\item{G_x}{Matrix defining the grouping of discrete design variables. Matching integers mean that the points are matched.}

\item{iFIMCalculationType}{\itemize{
\item \bold{******START OF FIM CALCULATION OPTIONS**********}}
Fisher Information Matrix type
\itemize{
\item 0=Full FIM
\item 1=Reduced FIM
\item 2=weighted models
\item 3=Loc models
\item 4=reduced FIM with derivative of SD of sigma as in PFIM
\item 5=FULL FIM parameterized with A,B,C matrices & derivative of variance
\item 6=Calculate one model switch at a time, good for large matrices
\item 7=Reduced FIM parameterized with A,B,C matrices & derivative of variance
}}

\item{iApproximationMethod}{Approximation method for model, 0=FO, 1=FOCE, 2=FOCEI, 3=FOI}

\item{iFOCENumInd}{Num individuals in each step of FOCE}

\item{prior_fim}{The prior FIM (added to calculated FIM)}

\item{strAutoCorrelationFile}{Filename and path, or function name, for the Autocorrelation function, 
empty string means no autocorrelation.}

\item{d_switch}{\itemize{
\item \bold{******START OF CRITERION SPECIFICATION OPTIONS**********}}
D-family design (1) or ED-family design (0) (with or without parameter uncertainty)}

\item{ofv_calc_type}{OFV calculation type for FIM 
\itemize{ 
\item 1 = "D-optimality". Determinant of the FIM: det(FIM)
\item 2 = "A-optimality".  Inverse of the sum of the expected parameter variances: 
1/trace_matrix(inv(FIM)) 
\item 4 = "lnD-optimality".  Natural logarithm of the determinant of the FIM: log(det(FIM)) 
\item 6 = "Ds-optimality". Ratio of the Determinant of the FIM and the Determinant of the uninteresting
rows and columns of the FIM: det(FIM)/det(FIM_u)
\item 7 = Inverse of the sum of the expected parameter RSE: 1/sum(get_rse(FIM,poped.db,use_percent=FALSE))
}}

\item{ds_index}{Ds_index is a vector set to 1 if a parameter is uninteresting, otherwise 0.
size=(1,num unfixed parameters). First unfixed bpop, then unfixed d, then unfixed docc and last unfixed sigma. 
Default is the fixed effects being important, everything else not important.  Used in conjunction with
\code{ofv_calc_type=6}.}

\item{strEDPenaltyFile}{Penalty function name or path and filename, empty string means no penalty.
User defined criterion can be defined this way.}

\item{ofv_fun}{User defined function used to compute the objective function. The function must have a poped database object as its first
argument and have "..." in its argument list.  Can be referenced as a function or as a file name where the function defined in the file has the same name as the file.
e.g. "cost.txt" has a function named "cost" in it.}

\item{iEDCalculationType}{\itemize{
\item \bold{******START OF E-FAMILY CRITERION SPECIFICATION OPTIONS**********}}
ED Integral Calculation, 0=Monte-Carlo-Integration, 1=Laplace Approximation, 2=BFGS Laplace Approximation  -- --}

\item{ED_samp_size}{Sample size for E-family sampling}

\item{bLHS}{How to sample from distributions in E-family calculations. 0=Random Sampling, 1=LatinHyperCube --}

\item{strUserDistributionFile}{Filename and path, or function name, for user defined distributions for E-family designs}

\item{nbpop}{\itemize{
\item \bold{******START OF Model parameters  SPECIFICATION OPTIONS**********}}
Number of typical values}

\item{NumRanEff}{Number of IIV parameters. Typically can be computed from other values and not supplied.}

\item{NumDocc}{Number of IOV variance parameters. Typically can be computed from other values and not supplied.}

\item{NumOcc}{Number of occasions. Typically can be computed from other values and not supplied.}

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

\item{covd}{Column major vector defining the covariances of the IIV variances. 
That is, from your full IIV matrix  \code{covd <-  IIV[lower.tri(IIV)]}.}

\item{sigma}{Matrix defining the variances can covariances of the residual variability terms of the model.
can also just supply the diagonal parameter values (variances) as a \code{c()}.}

\item{docc}{Matrix defining the IOV, the IOV variances and the IOV distribution as for d and bpop.}

\item{covdocc}{Column major vector defining the covariance of the IOV, as in covd.}

\item{notfixed_bpop}{\itemize{
\item \bold{******START OF Model parameters fixed or not  SPECIFICATION OPTIONS**********}}
Vector defining if a typical value is fixed or not (1=not fixed, 0=fixed). 
The parameter order of 'notfixed_bpop' is defined in the 'fg_fun' or 'fg_file'. If you use named 
arguments in 'notfixed_bpop' then the order of this vector can be rearranged to match the 'fg_fun' or 'fg_file'. 
See `reorder_parameter_vectors`.}

\item{notfixed_d}{Vector defining if a IIV is fixed or not (1=not fixed, 0=fixed). 
The parameter order of 'notfixed_d' is defined in the 'fg_fun' or 'fg_file'. If you use named 
arguments in 'notfixed_d' then the order of this vector can be rearranged to match the 'fg_fun' or 'fg_file'. 
See `reorder_parameter_vectors`. .}

\item{notfixed_covd}{Vector defining if a covariance IIV is fixed or not (1=not fixed, 0=fixed)}

\item{notfixed_docc}{Vector defining if an IOV variance is fixed or not (1=not fixed, 0=fixed)}

\item{notfixed_covdocc}{Vector row major order for lower triangular matrix defining if a covariance IOV is fixed or not (1=not fixed, 0=fixed)}

\item{notfixed_sigma}{Vector defining if a residual error parameter is fixed or not (1=not fixed, 0=fixed)}

\item{notfixed_covsigma}{Vector defining if a covariance residual error parameter is fixed or not (1=not fixed, 0=fixed). 
Default is fixed.}

\item{reorder_parameter_vectors}{If you use named arguments in 'bpop' or 'd' then PopED will try to figure out the order of the parameters 
based on what is found in the 'fg_fun'. See the resulting `poped_db$parameters` and make sure the order matches with 'fg_fun'.}

\item{bUseRandomSearch}{\itemize{
\item \bold{******START OF Optimization algorithm  SPECIFICATION OPTIONS**********}}
Use random search (1=TRUE, 0=FALSE)}

\item{bUseStochasticGradient}{Use Stochastic Gradient search (1=TRUE, 0=FALSE)}

\item{bUseLineSearch}{Use Line search (1=TRUE, 0=FALSE)}

\item{bUseExchangeAlgorithm}{Use Exchange algorithm (1=TRUE, 0=FALSE)}

\item{bUseBFGSMinimizer}{Use BFGS Minimizer (1=TRUE, 0=FALSE)}

\item{EACriteria}{Exchange Algorithm Criteria, 1 = Modified, 2 = Fedorov}

\item{strRunFile}{Filename and path, or function name, for a run file that is used instead of the regular PopED call.}

\item{poped_version}{\itemize{
\item \bold{******START OF Labeling and file names  SPECIFICATION OPTIONS**********}}
The current PopED version}

\item{modtit}{The model title}

\item{output_file}{Filename and path of the output file during search}

\item{output_function_file}{Filename suffix of the result function file}

\item{strIterationFileName}{Filename and path for storage of current optimal design}

\item{user_data}{\itemize{
\item \bold{******START OF Miscellaneous SPECIFICATION OPTIONS**********}}
User defined data structure that, for example could be used to send in data to the model}

\item{ourzero}{Value to interpret as zero in design}

\item{dSeed}{The seed number used for optimization and sampling -- integer or -1 which creates a random seed \code{as.integer(Sys.time())} or NULL.}

\item{line_opta}{Vector for line search on continuous design variables (1=TRUE,0=FALSE)}

\item{line_optx}{Vector for line search on discrete design variables (1=TRUE,0=FALSE)}

\item{bShowGraphs}{Use graph output during search}

\item{use_logfile}{If a log file should be used (0=FALSE, 1=TRUE)}

\item{m1_switch}{Method used to calculate M1 
(0=Complex difference, 1=Central difference, 20=Analytic derivative, 30=Automatic differentiation)}

\item{m2_switch}{Method used to calculate M2
(0=Central difference, 1=Central difference, 20=Analytic derivative, 30=Automatic differentiation)}

\item{hle_switch}{Method used to calculate linearization of residual error
(0=Complex difference, 1=Central difference, 30=Automatic differentiation)}

\item{gradff_switch}{Method used to calculate the gradient of the model
(0=Complex difference, 1=Central difference, 20=Analytic derivative, 30=Automatic differentiation)}

\item{gradfg_switch}{Method used to calculate the gradient of the parameter vector g
(0=Complex difference, 1=Central difference, 20=Analytic derivative, 30=Automatic differentiation)}

\item{grad_all_switch}{Method used to calculate all the gradients
(0=Complex difference, 1=Central difference)}

\item{rsit_output}{Number of iterations in random search between screen output}

\item{sgit_output}{Number of iterations in stochastic gradient search between screen output}

\item{hm1}{Step length of derivative of linearized model w.r.t. typical values}

\item{hlf}{Step length of derivative of model w.r.t. g}

\item{hlg}{Step length of derivative of g w.r.t. b}

\item{hm2}{Step length of derivative of variance w.r.t. typical values}

\item{hgd}{Step length of derivative of OFV w.r.t. time}

\item{hle}{Step length of derivative of model w.r.t. sigma}

\item{AbsTol}{The absolute tolerance for the diff equation solver}

\item{RelTol}{The relative tolerance for the diff equation solver}

\item{iDiffSolverMethod}{The diff equation solver method, NULL as default.}

\item{bUseMemorySolver}{If the differential equation results should be stored in memory (1) or not (0)}

\item{rsit}{Number of Random search iterations}

\item{sgit}{Number of stochastic gradient iterations}

\item{intrsit}{Number of Random search iterations with discrete optimization.}

\item{intsgit}{Number of Stochastic Gradient search iterations with discrete optimization}

\item{maxrsnullit}{Iterations until adaptive narrowing in random search}

\item{convergence_eps}{Stochastic Gradient convergence value,
(difference in OFV for D-optimal, difference in gradient for ED-optimal)}

\item{rslxt}{Random search locality factor for sample times}

\item{rsla}{Random search locality factor for covariates}

\item{cfaxt}{Stochastic Gradient search first step factor for sample times}

\item{cfaa}{Stochastic Gradient search first step factor for covariates}

\item{bGreedyGroupOpt}{Use greedy algorithm for group assignment optimization}

\item{EAStepSize}{Exchange Algorithm StepSize}

\item{EANumPoints}{Exchange Algorithm NumPoints}

\item{EAConvergenceCriteria}{Exchange Algorithm Convergence Limit/Criteria}

\item{bEANoReplicates}{Avoid replicate samples when using Exchange Algorithm}

\item{BFGSConvergenceCriteriaMinStep}{BFGS Minimizer Convergence Criteria Minimum Step}

\item{BFGSProjectedGradientTol}{BFGS Minimizer Convergence Criteria Normalized Projected Gradient Tolerance}

\item{BFGSTolerancef}{BFGS Minimizer Line Search Tolerance f}

\item{BFGSToleranceg}{BFGS Minimizer Line Search Tolerance g}

\item{BFGSTolerancex}{BFGS Minimizer Line Search Tolerance x}

\item{ED_diff_it}{Number of iterations in ED-optimal design to calculate convergence criteria}

\item{ED_diff_percent}{ED-optimal design convergence criteria in percent}

\item{line_search_it}{Number of grid points in the line search}

\item{Doptim_iter}{Number of iterations of full Random search and full Stochastic Gradient if line search is not used}

\item{iCompileOption}{\bold{******START OF PARALLEL OPTIONS**********} Compile options for PopED
\itemize{
\item -1 = No compilation,
\item 0 or 3 = Full compilation,
\item 1 or 4 = Only using MCC (shared lib),
\item 2 or 5 = Only MPI,
\item Option 0,1,2 runs PopED and option 3,4,5 stops after compilation
}}

\item{iUseParallelMethod}{Parallel method to use (0 = Matlab PCT, 1 = MPI)}

\item{MCC_Dep}{Additional dependencies used in MCC compilation (mat-files), if several space separated}

\item{strExecuteName}{Compilation output executable name}

\item{iNumProcesses}{Number of processes to use when running in parallel (e.g. 3 = 2 workers, 1 job manager)}

\item{iNumChunkDesignEvals}{Number of design evaluations that should be evaluated in each process before getting new work from job manager}

\item{Mat_Out_Pre}{The prefix of the output mat file to communicate with the executable}

\item{strExtraRunOptions}{Extra options send to e$g. the MPI executable or a batch script, see execute_parallel$m for more information and options}

\item{dPollResultTime}{Polling time to check if the parallel execution is finished}

\item{strFunctionInputName}{The file containing the popedInput structure that should be used to evaluate the designs}

\item{bParallelRS}{If the random search is going to be executed in parallel}

\item{bParallelSG}{If the stochastic gradient search is going to be executed in parallel}

\item{bParallelMFEA}{If the modified exchange algorithm is going to be executed in parallel}

\item{bParallelLS}{If the line search is going to be executed in parallel}
}
\value{
A PopED database
}
\description{
This function takes the input file (a previously created poped database) supplied by the user, or function arguments, 
and creates a database that can then be used to 
run all other PopED functions.  The function supplies default values to elements of the 
database that are not specified in the
input file or as function arguments. Default arguments are supplied in the Usage section 
(easiest to use a text search to find values you are interested in).
}
\examples{
## Warfarin example from software comparison in:
## Nyberg et al., "Methods and software tools for design evaluation 
##   for population pharmacokinetics-pharmacodynamics studies", 
##   Br. J. Clin. Pharm., 2014. 

library(PopED)

## find the parameters that are needed to define from the structural model
ff.PK.1.comp.oral.md.CL

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
poped.db <- create.poped.database(
  ff_fun=ff.PK.1.comp.oral.sd.CL,
  fg_fun=sfg,
  fError_fun=feps.prop,
  bpop=c(CL=0.15, V=8, KA=1.0, Favail=1), 
  notfixed_bpop=c(1,1,1,0),
  d=c(CL=0.07, V=0.02, KA=0.6), 
  sigma=0.01,
  groupsize=32,
  xt=c( 0.5,1,2,6,24,36,72,120),
  minxt=0,
  maxxt=120,
  a=70)


## evaluate initial design
evaluate_design(poped.db)
}
\seealso{
Other poped_input: 
\code{\link{convert_variables}()},
\code{\link{create_design}()},
\code{\link{create_design_space}()},
\code{\link{downsizing_general_design}()},
\code{\link{poped.choose}()}
}
\concept{poped_input}
