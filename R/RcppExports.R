# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

rcpp_init_stepsize_diag <- function(theta0, Minv, Misqrt, X, B, param) {
    .Call('_SPQR_rcpp_init_stepsize_diag', PACKAGE = 'SPQR', theta0, Minv, Misqrt, X, B, param)
}

rcpp_init_stepsize_dense <- function(theta0, Minv, Misqrt, X, B, param) {
    .Call('_SPQR_rcpp_init_stepsize_dense', PACKAGE = 'SPQR', theta0, Minv, Misqrt, X, B, param)
}

rcpp_nuts_diag <- function(q0, X, B, param, epsilon, Minv, Misqrt, max_tree_depth, info) {
    .Call('_SPQR_rcpp_nuts_diag', PACKAGE = 'SPQR', q0, X, B, param, epsilon, Minv, Misqrt, max_tree_depth, info)
}

rcpp_nuts_dense <- function(q0, X, B, param, epsilon, Minv, Misqrt, max_tree_depth, info) {
    .Call('_SPQR_rcpp_nuts_dense', PACKAGE = 'SPQR', q0, X, B, param, epsilon, Minv, Misqrt, max_tree_depth, info)
}

rcpp_hmc_diag <- function(q0, X, B, param, epsilon, Minv, Misqrt, int_time, info) {
    .Call('_SPQR_rcpp_hmc_diag', PACKAGE = 'SPQR', q0, X, B, param, epsilon, Minv, Misqrt, int_time, info)
}

rcpp_hmc_dense <- function(q0, X, B, param, epsilon, Minv, Misqrt, int_time, info) {
    .Call('_SPQR_rcpp_hmc_dense', PACKAGE = 'SPQR', q0, X, B, param, epsilon, Minv, Misqrt, int_time, info)
}

loglik_vec <- function(theta, X, B, param) {
    .Call('_SPQR_loglik_vec', PACKAGE = 'SPQR', theta, X, B, param)
}

logprob <- function(theta, X, B, param) {
    .Call('_SPQR_logprob', PACKAGE = 'SPQR', theta, X, B, param)
}

glogprob <- function(theta, X, B, param) {
    .Call('_SPQR_glogprob', PACKAGE = 'SPQR', theta, X, B, param)
}

