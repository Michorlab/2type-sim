# Moment functions
m1 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  ancestors * exp((alpha1 - beta1) * t)
}

m2 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  ancestors * nu * (exp((alpha1 - beta1) * t) - exp((alpha2 - beta2) * t)) /
    ((alpha1 - beta1) - (alpha2 - beta2))
}

var1 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  (1 / (alpha1 - alpha2 - beta1 + beta2) *
    (
      (nu * (alpha2 + beta2) * exp((alpha2 - beta2) * t) / (2 * alpha1 - alpha2 - 2 * beta1 + beta2)) -
        ((2 * beta1 * (alpha1 - alpha2 - beta1 + beta2) + (alpha2 + beta2) * nu) * exp((alpha1 - beta1) * t) / (alpha1 - beta1)) +
        (exp(2 * t * (alpha1 - beta1)) * ((alpha2 + beta2) * nu / (-2 * alpha1 + alpha2 + 2 * beta1 - beta2) + (2 * beta1 * (alpha1 - alpha2 - beta1 + beta2) + nu*(alpha2 + beta2)) / (alpha1 - beta1)))
    )) * ancestors^2
}

var2<- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  (
    (
      2 * beta2 * nu * exp(t * (alpha2 - beta2)) * (-alpha1 + 2 * alpha2 + beta1 - 2 * beta2) - 
        exp(2 * t * (alpha2 - beta2)) * (-alpha1 + alpha2 + beta1 - beta2) * ((alpha1 + beta1) * (alpha2 - beta2) + nu * (alpha2 + beta2)) +
        (alpha2 - beta2) * exp(t * (alpha1 - beta1)) * (nu * (-alpha1 + alpha2 + beta1 - 3 * beta2) - (alpha1 + beta1) * (alpha1 - alpha2 - beta1 + beta2))
    ) /
      ((alpha2 - beta2) * (-alpha1 + alpha2 + beta1 - beta2) * (alpha1 - 2 * alpha2 - beta1 + 2 * beta2)) -
      (nu^2 * (exp(t * (alpha1 - beta1)) - exp(t * (alpha2 - beta2)))^2) / (alpha1 - alpha2 - beta1 + beta2)^2
  ) * ancestors^2
}

#' r2type
#' 
#' r2type generates random numbers from a 2D distribution where probabilities
#' are described in a matrix. The function samples by running through the
#' matrix diagonally from (0,0).
#' 
#' Use this method after generating a distribution when you want to refer
#' to that distribution multiple times since the distribution is stored in
#' memory.
#' 
#' @param N number of samples to generate
#' @param pdf pdf matrix generated from p2type
#' 
#' @return matrix of randomly generated 2-dimensional values
#' 
#' @export
r2type <- function(N, pdf, ancestors = 1)
{
  if(N < 1 || ancestors < 1) return(cbind(0,0))
  
  x_dom_size <- nrow(pdf)
  y_dom_size <- ncol(pdf)
  x_marg <- rowSums(pdf)
  x <- sample(1:x_dom_size, N*ancestors, replace = TRUE, prob = x_marg) - 1
  y <- sapply(x, function(x) sample(1:y_dom_size, 1, replace = TRUE, prob = pdf[x + 1, ])) - 1
  
  cbind(colSums(matrix(x, nrow = ancestors)), colSums(matrix(y, nrow = ancestors)))
}

#' rbdm
#' 
#' rbdm generates a 2-type birth-death-mutation process given the rate parameters
#' and returns basic summary statistics, the distribution function used, and the
#' simulated data.
#' 
#' Use this to generate many complete birth-death-mutation process
#' 
#' @param t time to simulate
#' @param N number of samples to generate
#' @param ancestors pdf matrix generated from p2type
#' @param alpha1
#' @param beta1
#' @param nu
#' @param alpha2
#' @param beta2

#' @return matrix of randomly generated 2-dimensional values
#' 
#' @export
rbdm <- function(t, N, alpha1, beta1, nu, alpha2, beta2, ancestors = 1)
{
  # Determine expectation and variances
  mean = c(m1(t, ancestors, alpha1, beta1, nu, alpha2, beta2),
           m2(t, ancestors, alpha1, beta1, nu, alpha2, beta2))
  variance = c(var1(t, ancestors, alpha1, beta1, nu, alpha2, beta2),
               var2(t, ancestors, alpha1, beta1, nu, alpha2, beta2))
  # TODO use mean and variance to get idea of expected growth in order
  # to adaptively reduce the space since can probably only generate
  # up to 2^11 or 2^12 maximum at a time
  
  # Generate distribution function
  pdf = p2type(t, alpha1, beta1, nu, alpha2, beta2, ancestors = 1, domain_size = 10)
  # return simulated values
  r2type(N, pdf, 1)
}