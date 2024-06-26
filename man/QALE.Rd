% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/QALE.R
\name{QALE}
\alias{QALE}
\title{quantile accumulated local effects (ALE)}
\usage{
QALE(
  object,
  var.index,
  tau = seq(0.1, 0.9, 0.1),
  n.bins = 40,
  ci.level = 0,
  getAll = FALSE,
  pred.fun = NULL
)
}
\arguments{
\item{object}{An object of class \code{SPQR}.}

\item{var.index}{a numeric scalar or length-two vector of indices of the
covariates for which the ALEs will be calculated. When \code{length(var.index) = 1},
the function computes the main effect for \code{X[,var.index]}. When \code{length(var.index) = 2},
the function computes the interaction effect between \code{X[,var.index[1]]} and \code{X[,var.index[2]]}.}

\item{tau}{The quantiles of interest.}

\item{n.bins}{the maximum number of intervals into which the covariate range is divided when
  calculating the ALEs. The actual number of intervals depends on the number of unique values in
\code{X[,var.index]}. When \code{length(var.index) = 2}, \code{n.bins} is applied to both covariates.}

\item{ci.level}{The credible level for computing the pointwise credible intervals for ALE
when \code{length(var.index) = 1}. The default is 0 indicating no credible intervals should be computed.}

\item{getAll}{If \code{TRUE} and \code{length(var.index) = 1}, extracts all posterior samples of ALE.}

\item{pred.fun}{A function that will be used instead of \code{predict.SPQR()}
for computing predicted quantiles given covariates. This can be useful when the user wants to compare
the QALE calculated using SPQR to that using other quantile regression models, or maybe that using
the true model in a simulation study.}
}
\value{
\item{x}{If \code{length(var.index) = 1}, a \code{(n.bins+1)}-length vector specifying the ordered
predictor values at which the ALE plot function is calculated. These are the break points for
the \code{n.bins} intervals into which the predictor range is divided, plus the lower boundary of the first
interval and the upper boundary of the last interval. If \code{length(var.index) = 2}, a list of two
such vectors, the first containing the \code{X[,var.index[1]]} values and the second containing
the \code{X[,var.index[2]]} values at which the ALE plot function is calculated.}

\item{ALE}{If \code{length(var.index) = 1}, a \code{(n.bins+1)} by \code{length(tau)} matrix of predicted
ALE values for every combination of \code{x} and \code{tau}. If \code{length(var.index) = 2}, a 3-dimensional array
of predicted ALE values. Each slice corresponds to a quantile. Within each slice, the rows correspond to
\code{X[,var.index[1]]} and the columns correspond to \code{X[,var.index[2]]}.}
}
\description{
Computes the quantile ALEs of a \code{SPQR} class object. The function plots the ALE main effects across
\code{tau} using line plots for a single covariate, and the ALE interaction effects across \code{tau}
using contour plots for two covariates .
}
\examples{
\donttest{
set.seed(919)
n <- 200
X <- runif(n,0,2)
Y <- rnorm(n,X^2,0.3+X/2)
control <- list(iter = 200, warmup = 150, thin = 1)
fit <- SPQR(X=X, Y=Y, n.knots=12, n.hidden=3, method="MCMC",
            control=control, normalize=TRUE, verbose = FALSE)

## compute quantile ALE main effect of X at tau = 0.2,0.5,0.8
ale <- QALE(fit, var.index=1, tau=c(0.2,0.5,0.8))
}
}
