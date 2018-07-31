# Moment functions
.m1 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  ancestors * exp((alpha1 - beta1) * t)
}

.m2 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  ancestors * nu * (exp((alpha1 - beta1) * t) - exp((alpha2 - beta2) * t)) /
    ((alpha1 - beta1) - (alpha2 - beta2))
}

.var1 <- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
{
  (1 / (alpha1 - alpha2 - beta1 + beta2) *
    (
      (nu * (alpha2 + beta2) * exp((alpha2 - beta2) * t) / (2 * alpha1 - alpha2 - 2 * beta1 + beta2)) -
        ((2 * beta1 * (alpha1 - alpha2 - beta1 + beta2) + (alpha2 + beta2) * nu) * exp((alpha1 - beta1) * t) / (alpha1 - beta1)) +
        (exp(2 * t * (alpha1 - beta1)) * ((alpha2 + beta2) * nu / (-2 * alpha1 + alpha2 + 2 * beta1 - beta2) + (2 * beta1 * (alpha1 - alpha2 - beta1 + beta2) + nu*(alpha2 + beta2)) / (alpha1 - beta1)))
    )) * ancestors^2
}

.var2<- function(t, ancestors, alpha1, beta1, nu, alpha2, beta2)
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

#' ssa.single
#' 
#' ssa.single generates a single run from the Stochastic Simulation Algorithm
#' under model 1 or 2. This can be used to compare to a distribution created in
#' the package.
#' 
#' @param t time of simulation
#' @param alpha1 type 1 birth rate
#' @param beta1 type 1 death rate
#' @param nu type 1 mutation rate (model 1 generates a single type 2 and model 2 generates a type 1 and type 2)
#' @param alpha2 type 2 birth rate
#' @param beta2 type 2 death rate
#' @param ancestors 2-element vector of number of ancestors
#' @param model 1 or 2 for the model used
#' 
#' 
#' @return 2-element vector containing the number of type 1 and type 2 individuals
#' 
#' @export
ssa.single <- function(t, alpha1, beta1, nu, alpha2, beta2, ancestors = c(1, 0), model = 2)
{
  curr_time <- 0
  z <- ancestors
  rate <- z[1] * (alpha1 + beta1 + nu) + z[2] * (alpha2 + beta2)
  while(curr_time < t & sum(z) > 0)
  {
    curr_time <- curr_time + rexp(1, rate)
    
    if(curr_time > t) break
    
    u <- runif(1, 0, rate)
    if(u <= z[1] * alpha1)
    {
      z[1] <- z[1] + 1
      rate <- rate + (alpha1 + beta1 + nu)
    }
    else if(u <= z[1] * (alpha1 + beta1))
    {
      z[1] <- z[1] - 1
      rate <- rate - (alpha1 + beta1 + nu)
    }
    else if(model == 1 & u <= z[1] * (alpha1 + beta1 + nu))
    {
      z[1] <- z[1] - 1
      z[2] <- z[2] + 1
      rate <- rate + (alpha2 + beta2) - (alpha1 + beta1 + nu)
    }
    else if(u <= z[1] * (alpha1 + beta1 + nu) + z[2] * alpha2)
    {
      z[2] <- z[2] + 1
      rate <- rate + (alpha2 + beta2)
    }
    else
    {
      z[2] <- z[2] - 1
      rate <- rate - (alpha2 + beta2)
    }
  }
  z
}

#' ssa
#' 
#' ssa generates multiple runs from the Stochastic Simulation Algorithm
#' under model 1 or 2. This can be used to compare to a distribution created in
#' the package.
#' 
#' @param N number of runs to generate
#' @param t time of simulation
#' @param alpha1 type 1 birth rate
#' @param beta1 type 1 death rate
#' @param nu type 1 mutation rate (model 1 generates a single type 2 and model 2 generates a type 1 and type 2)
#' @param alpha2 type 2 birth rate
#' @param beta2 type 2 death rate
#' @param ancestors 2-element vector of number of ancestors
#' @param model 1 or 2 for the model used
#' 
#' 
#' @return 2-element vector containing the number of type 1 and type 2 individuals
#' 
#' @export
ssa <- function(N = 1, t, alpha1, beta1, nu, alpha2, beta2, ancestors = c(1, 0), model = 2)
{
  t(replicate(N, ssa.single(t, alpha1, beta1, nu, alpha2, beta2, ancestors, model)))
}