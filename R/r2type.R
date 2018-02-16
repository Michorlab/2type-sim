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
r2type <- function(N, pdf)
{
  dom_size <- ncol(pdf)
  x_marg <- rowSums(pdf)
  x <- sample(1:dom_size, N, replace = TRUE, prob = x_marg)
  
  y <- sapply(x, function(x) sample(1:dom_size, 1, replace = TRUE, prob = pdf[x, ]))
  
  cbind(x-1, y-1)
}