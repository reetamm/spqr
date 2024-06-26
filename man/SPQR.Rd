% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SPQR.R
\docType{package}
\name{SPQR}
\alias{SPQR}
\title{Fitting SPQR models}
\usage{
SPQR(
  X,
  Y,
  n.knots = 10,
  n.hidden = 10,
  activation = c("tanh", "relu", "sigmoid"),
  method = c("MLE", "MAP", "MCMC"),
  prior = c("ARD", "GP", "GSM"),
  hyperpar = list(),
  control = list(),
  normalize = FALSE,
  verbose = TRUE,
  seed = NULL,
  ...
)
}
\arguments{
\item{X}{The covariate matrix (without intercept column)}

\item{Y}{The response vector.}

\item{n.knots}{The number of basis functions. Default: 10.}

\item{n.hidden}{A vector specifying the number of hidden neurons in each hidden layer. Default: 10.}

\item{activation}{The hidden layer activation. Either \code{"tanh"} (default) or \code{"relu"}.}

\item{method}{Method for estimating SPQR. One of \code{"MLE"}, \code{"MAP"} (default) or \code{"MCMC"}.}

\item{prior}{The prior model for variance hyperparameters. One of \code{"GP"}, \code{"ARD"} (default) or \code{"GSM"}.}

\item{hyperpar}{A list of named hyper-prior hyperparameters to use instead of the default values, including
\code{a_lambda}, \code{b_lambda}, \code{a_sigma} and \code{b_sigma}. The default value is 0.001 for all four
hyperparameters.}

\item{control}{A list of named and method-dependent parameters that allows finer
 control of the behavior of the computational approaches.

1. Parameters for MLE and MAP methods

\itemize{
  \item \code{use.GPU} If \code{TRUE} GPU computing will be used if \code{torch::cuda_is_available()} returns \code{TRUE}. Default: \code{FALSE}.
  \item \code{lr} The learning rate used by the Adam optimizer, i.e., \code{torch::optim_adam()}.
  \item \code{dropout} A length two vector specifying the dropout probabilities in the input and hidden layers respectively. The default is \code{c(0,0)} indicating no dropout.
  \item \code{batchnorm} If \code{TRUE} batch normalization will be used after each hidden activation.
  \item \code{epochs} The number of passes of the entire training dataset in gradient descent optimization. If \code{early.stopping.epochs} is used then this is the maximum number of passes. Default: 200.
  \item \code{batch.size} The size of mini batches for gradient calculation. Default: 128.
  \item \code{valid.pct} The fraction of data used as validation set. Default: 0.2.
  \item \code{early.stopping.epochs} The number of epochs before stopping if the validation loss does not decrease. Default: 10.
  \item \code{print.every.epochs} The number of epochs before next training progress in printed. Default: 10.
  \item \code{save.path} The path to save the fitted torch model. By default a folder named \code{"SPQR_model"} is created in the current working directory to store the model.
  \item \code{save.name} The name of the file to save the fitted torch model. Default is \code{"SPQR.model.pt"}.
}

2. Parameters for MCMC method

These parameters are similar to those in \code{rstan::stan()}. Detailed explanations can be found in
the Stan reference manual.

\itemize{
  \item \code{algorithm} The sampling algorithm; \code{"HMC"}: Hamiltonian Monte Carlo with dual-averaging, \code{"NUTS"}: No-U-Turn sampler (default).
  \item \code{iter} The number of MCMC iterations (including warmup). Default: 2000.
  \item \code{warmup} The number of warm-up/burn-in iterations for step-size and mass matrix adaptation. Default: 500.
  \item \code{thin} The number of iterations before saving next post-warmup samples. Default: 1.
  \item \code{stepsize} The discretization interval/step-size \eqn{\epsilon} of leap-frog integrator. Default is \code{NULL} which indicates that it will be adaptively selected during warm-up iterations.
  \item \code{metric} The type of mass matrix; \code{"unit"}: diagonal matrix of ones, \code{"diag"}: diagonal matrix with positive diagonal entries estimated during warmup iterations (default), \code{"dense"}: a dense, symmetric positive definite matrix with entries estimated during warm-up iterations.
  \item \code{delta} The target Metropolis acceptance rate. Default: 0.9.
  \item \code{max.treedepth} The maximum tree depth in NUTS. Default: 6.
  \item \code{int.time} The integration time in HMC. The number of leap-frog steps is calculated as \eqn{L_{\epsilon}=\lfloor t/\epsilon\rfloor}. Default: 0.3.
}}

\item{normalize}{If \code{TRUE}, all covariates will be normalized to take values between [0,1].}

\item{verbose}{If \code{TRUE} (default), training progress will be printed.}

\item{seed}{Random number generation seed.}

\item{...}{other parameters to pass to \code{control}.}
}
\value{
An object of class \code{SPQR}. A list containing mostly internal model fitting
information to be used by helper functions.
}
\description{
Main function of the package. Fits SPQR using the maximum likelihood estimation (MLE), maximum \emph{a posterior} (MAP) or
Markov chain Monte Carlo (MCMC) method. Returns an object of S3 class \code{SPQR}.
}
\examples{
\donttest{
set.seed(919)
n <- 200
X <- rbinom(n, 1, 0.5)
Y <- rnorm(n, X, 0.8)
control <- list(iter = 200, warmup = 150, thin = 1)
fit <- SPQR(X = X, Y = Y, method = "MCMC", control = control,
            normalize = TRUE, verbose = FALSE)

## summarize output
summary(fit)

## plot estimated PDF
plotEstimator(fit, type = "PDF", X = 0)
}
}
\references{
Xu SG, Reich BJ (2021). \emph{Bayesian Nonparametric Quantile Process Regression and Estimation of Marginal Quantile Effects.} Biometrics. \doi{10.1111/biom.13576}
}
