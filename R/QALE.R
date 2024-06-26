#' @title quantile accumulated local effects (ALE)
#' @description
#' Computes the quantile ALEs of a \code{SPQR} class object. The function plots the ALE main effects across
#' \code{tau} using line plots for a single covariate, and the ALE interaction effects across \code{tau}
#' using contour plots for two covariates .
#'
#' @param object An object of class \code{SPQR}.
#' @param var.index a numeric scalar or length-two vector of indices of the
#'   covariates for which the ALEs will be calculated. When \code{length(var.index) = 1},
#'   the function computes the main effect for \code{X[,var.index]}. When \code{length(var.index) = 2},
#'   the function computes the interaction effect between \code{X[,var.index[1]]} and \code{X[,var.index[2]]}.
#' @param tau The quantiles of interest.
#' @param n.bins  the maximum number of intervals into which the covariate range is divided when
#'   calculating the ALEs. The actual number of intervals depends on the number of unique values in
#' \code{X[,var.index]}. When \code{length(var.index) = 2}, \code{n.bins} is applied to both covariates.
#' @param ci.level The credible level for computing the pointwise credible intervals for ALE
#'   when \code{length(var.index) = 1}. The default is 0 indicating no credible intervals should be computed.
#' @param getAll If \code{TRUE} and \code{length(var.index) = 1}, extracts all posterior samples of ALE.
#' @param pred.fun  A function that will be used instead of \code{predict.SPQR()}
#'   for computing predicted quantiles given covariates. This can be useful when the user wants to compare
#'   the QALE calculated using SPQR to that using other quantile regression models, or maybe that using
#'   the true model in a simulation study.
#'
#' @return
#' \item{x}{If \code{length(var.index) = 1}, a \code{(n.bins+1)}-length vector specifying the ordered
#' predictor values at which the ALE plot function is calculated. These are the break points for
#' the \code{n.bins} intervals into which the predictor range is divided, plus the lower boundary of the first
#' interval and the upper boundary of the last interval. If \code{length(var.index) = 2}, a list of two
#' such vectors, the first containing the \code{X[,var.index[1]]} values and the second containing
#' the \code{X[,var.index[2]]} values at which the ALE plot function is calculated.}
#'
#' \item{ALE}{If \code{length(var.index) = 1}, a \code{(n.bins+1)} by \code{length(tau)} matrix of predicted
#' ALE values for every combination of \code{x} and \code{tau}. If \code{length(var.index) = 2}, a 3-dimensional array
#' of predicted ALE values. Each slice corresponds to a quantile. Within each slice, the rows correspond to
#' \code{X[,var.index[1]]} and the columns correspond to \code{X[,var.index[2]]}.}
#'
#' @importFrom stats quantile
#'
#' @examples
#' \donttest{
#' set.seed(919)
#' n <- 200
#' X <- runif(n,0,2)
#' Y <- rnorm(n,X^2,0.3+X/2)
#' control <- list(iter = 200, warmup = 150, thin = 1)
#' fit <- SPQR(X=X, Y=Y, n.knots=12, n.hidden=3, method="MCMC",
#'             control=control, normalize=TRUE, verbose = FALSE)
#'
#' ## compute quantile ALE main effect of X at tau = 0.2,0.5,0.8
#' ale <- QALE(fit, var.index=1, tau=c(0.2,0.5,0.8))
#' }
#' @export
QALE <- function(object, var.index, tau = seq(0.1,0.9,0.1), n.bins = 40, ci.level = 0,
                 getAll = FALSE, pred.fun = NULL) {

  if (!is.null(pred.fun) || object$method != "MCMC") {
    ci.level <- 0
    getAll <- FALSE
  }
  if (length(var.index) > 2)
    stop("`var.index` should be a vector of length one or two.")
  stopifnot(is.numeric(ci.level))
  if (ci.level < 0 || ci.level >=1) stop("`ci.level` should be between 0 and 1")
  if (ci.level > 0) getAll <- TRUE
  if (!is.null(pred.fun)) stopifnot(is.function(pred.fun))

  X <- object$X
  N <- nrow(X)  # sample size
  d <- ncol(X)  # number of predictor variables
  J <- var.index # predictor index
  K <- n.bins # number of partition on each X_j

  firstCheck <- class(X[,J[1]]) == "numeric" || class(X[,J[1]]) == "integer"
  if (length(J) == 1) { # calculate main effects ALE plot
    if (!firstCheck)
      stop("X[,var.index] must be numeric or integer.")
    # find the vector of z values corresponding to the quantiles of X[,J]
    z <- c(min(X[,J]), as.numeric(quantile(X[,J],seq(1/K,1,length.out=K), type=1)))  # vector of K+1 z values
    z <- unique(z)  # necessary if X[,J] is discrete, in which case z could have repeated values
    K <- length(z)-1 # reset K to the number of unique quantile points
    fJ <- numeric(K)
    # group training rows into bins based on z
    a1 <- as.numeric(cut(X[,J], breaks=z, include.lowest=TRUE)) # N-length index vector indicating into which z-bin the training rows fall
    X1 <- X
    X2 <- X
    X1[,J] <- z[a1]
    X2[,J] <- z[a1+1]
    if (is.null(pred.fun)) {
      y.hat1 <- predict.SPQR(object=object, X=X1, type="QF", tau=tau, getAll=getAll)
      y.hat2 <- predict.SPQR(object=object, X=X2, type="QF", tau=tau, getAll=getAll)
    } else {
      y.hat1 <- pred.fun(X=X1, tau=tau)
      y.hat2 <- pred.fun(X=X2, tau=tau)
    }
    Delta <- y.hat2-y.hat1
    if (is.null(dim(Delta))) dim(Delta) <- c(N,1)
    if (getAll) {
      nnn <- length(object$model)
      # Delta is N x length(tau) x nnn
      DDelta <- array(0, dim = c(K, length(tau), nnn))
      fJ <- array(0, dim=c(K+1, length(tau), nnn))
      for (i in 1:nnn) {
        for (j in 1:length(tau)) {
          DDelta[,j,i] <- as.numeric(tapply(Delta[,j,i], a1, mean))
        }
        fJ[,,i] <- rbind(0,apply(DDelta[,,i,drop=FALSE],2,cumsum))
      }
      if (ci.level > 0) {
        .fJ <- array(0,dim=c(K+1, length(tau), 3))
        .fJ[,,1] <- apply(fJ,1:2,quantile,probs=(1-ci.level)/2)
        .fJ[,,2] <- apply(fJ,1:2,mean)
        .fJ[,,3] <- apply(fJ,1:2,quantile,probs=(1+ci.level)/2)
        fJ <- .fJ
        rm(.fJ)
        dimnames(fJ)[[3]] <- c("lower.bound","mean","upper.bound")
        names(dimnames(fJ))[3] <- "CI"
      } else {
        dimnames(fJ)[[3]] <- 1:nnn
        names(dimnames(fJ))[3] <- "Iteration"
      }
    } else {
      # Delta is N x length(tau)
      DDelta <- matrix(0, nrow = K, ncol = length(tau))
      for (i in 1:length(tau)) {
        DDelta[,i] <- as.numeric(tapply(Delta[,i], a1, mean)) #K-length vector of averaged local effect values
      }
      fJ <- rbind(0,apply(DDelta,2,cumsum)) #K+1 length vector
    }
    x <- z
    colnames(fJ) <- paste0(tau*100, "%")
    names(dimnames(fJ))[1:2] <- c("X","tau")
    #end of if (length(J) == 1) statement
  } else { #calculate second-order effects ALE plot
    secondCheck <- class(X[,J[2]]) == "numeric" || class(X[,J[2]]) == "integer"
    if (!(firstCheck && secondCheck))
      stop("Both X[,var.index[1]] and X[,var.index[2]] must be numeric or integer.")

    #find the vectors of z values corresponding to the quantiles of X[,J[1]] and X[,J[2]]
    z1 <- c(min(X[,J[1]]), as.numeric(quantile(X[,J[1]],seq(1/K,1,length.out=K), type=1)))  #vector of K+1 z values for X[,J[1]]
    z1 <- unique(z1)  #necessary if X[,J(1)] is discrete, in which case z1 could have repeated values
    K1 <- length(z1)-1 #reset K1 to the number of unique quantile points
    if (K1 == 1)
      stop("X[,var.index[1]] should have at least 3 unique values.")
    #group training rows into bins based on z1
    a1 <- as.numeric(cut(X[,J[1]], breaks=z1, include.lowest=TRUE)) #N-length index vector indicating into which z1-bin the training rows fall
    z2 <- c(min(X[,J[2]]), as.numeric(quantile(X[,J[2]],seq(1/K,1,length.out=K), type=1)))  #vector of K+1 z values for X[,J[2]]
    z2 <- unique(z2)  #necessary if X[,J(2)] is discrete, in which case z2 could have repeated values
    K2 <- length(z2)-1 #reset K2 to the number of unique quantile points
    if (K2 == 1)
      stop("X[,var.index[2]] should have at least 3 unique values.")
    fJ <- matrix(0,K1,K2)  #rows correspond to X[,J(1)] and columns to X[,J(2)]
    #group training rows into bins based on z2
    a2 <- as.numeric(cut(X[,J[2]], breaks=z2, include.lowest=TRUE)) #N-length index vector indicating into which z2-bin the training rows fall
    X11 <- X  #matrix with low X[,J[1]] and low X[,J[2]]
    X12 <- X  #matrix with low X[,J[1]] and high X[,J[2]]
    X21 <- X  #matrix with high X[,J[1]] and low X[,J[2]]
    X22 <- X  #matrix with high X[,J[1]] and high X[,J[2]]
    X11[,J] <- cbind(z1[a1], z2[a2])
    X12[,J] <- cbind(z1[a1], z2[a2+1])
    X21[,J] <- cbind(z1[a1+1], z2[a2])
    X22[,J] <- cbind(z1[a1+1], z2[a2+1])
    if (is.null(pred.fun)) {
      y.hat11 <- predict.SPQR(object=object, X=X11, type="QF", tau=tau)
      y.hat12 <- predict.SPQR(object=object, X=X12, type="QF", tau=tau)
      y.hat21 <- predict.SPQR(object=object, X=X21, type="QF", tau=tau)
      y.hat22 <- predict.SPQR(object=object, X=X22, type="QF", tau=tau)
    } else {
      y.hat11 <- pred.fun(X=X11, tau=tau)
      y.hat12 <- pred.fun(X=X12, tau=tau)
      y.hat21 <- pred.fun(X=X21, tau=tau)
      y.hat22 <- pred.fun(X=X22, tau=tau)
    }
    .Delta <- (y.hat22-y.hat21)-(y.hat12-y.hat11)  #N-length vector of individual local effect values
    if (is.null(dim(.Delta))) dim(.Delta) <- c(N, length(tau))
    Delta <- array(dim=c(K1,K2,length(tau)))
    for (dd in 1:length(tau)) {
      #K1xK2 matrix of averaged local effects, which includes NA values if a cell is empty
      Delta[,,dd] <- as.matrix(tapply(.Delta[,dd], list(a1, a2), mean))
    }
    #replace NA values in Delta by the Delta value in their nearest neighbor non-NA cell
    NA.Delta <- is.na(Delta[,,1])  #K1xK2 matrix indicating cells that contain no observations
    NA.ind <- which(NA.Delta, arr.ind=T, useNames = F)  #2-column matrix of row and column indices for NA cells
    if (!is.null(nrow(NA.ind))) {
      if (nrow(NA.ind) > 0) {
        notNA.ind <- which(!NA.Delta, arr.ind=T, useNames = F)  #2-column matrix of row and column indices for non-NA cells
        range1 <- max(z1)-min(z1)
        range2 <- max(z2)-min(z2)
        Z.NA <- cbind((z1[NA.ind[,1]] + z1[NA.ind[,1]+1])/2/range1, (z2[NA.ind[,2]] + z2[NA.ind[,2]+1])/2/range2) #standardized {z1,z2} values for NA cells corresponding to each row of NA.ind
        Z.notNA <- cbind((z1[notNA.ind[,1]] + z1[notNA.ind[,1]+1])/2/range1, (z2[notNA.ind[,2]] + z2[notNA.ind[,2]+1])/2/range2) #standardized {z1,z2} values for non-NA cells corresponding to each row of notNA.ind
        nbrs <- yaImpute::ann(Z.notNA, Z.NA, k=1, verbose = F)$knnIndexDist[,1] #vector of row indices (into Z.notNA) of nearest neighbor non-NA cells for each NA cell
        for (dd in 1:length(tau)) {
          Delta[,,dd][NA.ind] <- Delta[,,dd][matrix(notNA.ind[nbrs,], ncol=2)]
        }#Set Delta for NA cells equal to Delta for their closest neighbor non-NA cell.
      } #end of if (nrow(NA.ind) > 0) statement
      #accumulate the values in Delta
    }
    fJ <- array(0,c(K1,K2,length(tau)))
    for (dd in 1:length(tau)) {
      fJ[,,dd] <- apply(t(apply(Delta[,,dd],1,cumsum)),2,cumsum)
    }
    .fJ <- fJ
    fJ <- array(0,c(K1+1,K2+1,length(tau)))
    fJ[-1,-1,] <- .fJ
    #add a first row and first column to fJ that are all zeros
    #now subtract the lower-order effects from fJ
    b <- as.matrix(table(a1,a2))  #K1xK2 cell count matrix (rows correspond to X[,J[1]]; columns to X[,J[2]])
    b1 <- apply(b,1,sum)  #K1x1 count vector summed across X[,J[2]], as function of X[,J[1]]
    b2 <- apply(b,2,sum)  #K2x1 count vector summed across X[,J[1]], as function of X[,J[2]]
    Delta <- fJ[2:(K1+1),,,drop=FALSE]-fJ[1:K1,,,drop=FALSE] #K1x(K2+1) matrix of differenced fJ values, differenced across X[,J[1]]
    tmp <- (Delta[,1:K2,,drop=FALSE]+Delta[,2:(K2+1),,drop=FALSE])/2
    b.Delta <- array(b,c(K1,K2,length(tau)))*tmp
    Delta.Ave <- apply(b.Delta,c(1,3),sum)/b1
    fJ1 <- rbind(0,apply(Delta.Ave,2,cumsum))
    Delta <- fJ[,2:(K2+1),,drop=FALSE]-fJ[,1:K2,,drop=FALSE] #(K1+1)xK2 matrix of differenced fJ values, differenced across X[,J[2]]
    tmp <- (Delta[1:K1,,,drop=FALSE]+Delta[2:(K1+1),,,drop=FALSE])/2
    b.Delta <- array(b,c(K1,K2,length(tau)))*tmp
    Delta.Ave <- apply(b.Delta,c(2,3),sum)/b2
    fJ2 <- rbind(0,apply(Delta.Ave,2,cumsum))
    for (dd in 1:length(tau)) {
      fJ[,,dd] <- fJ[,,dd] - outer(fJ1[,dd],rep(1,K2+1)) - outer(rep(1,K1+1),fJ2[,dd])
    }
    x <- list(z1, z2)
    dimnames(fJ)[[3]] <- paste0(tau*100, "%")
    names(dimnames(fJ)) <- c(paste0("X",var.index),"tau")
    #end of "if (length(J) == 2)" statement
  }
  return(list(x = x, ALE = fJ))
}
