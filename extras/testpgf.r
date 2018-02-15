setwd("~/Dropbox/inv_fourier_pgf")

probs <- read.csv("prob_table.txt", header = F)
probs <- probs[,-ncol(probs)]
probs <- as.matrix(probs)

probs[1:10,1:10]

# Generate random numbers
N <- 3000

x_marg <- rowSums(probs)
x_marg <- sample(1:ncol(probs), size = N, prob = x_marg, replace = T)
y_marg <- sapply(x_marg, function(x) sample(1:nrow(probs), size = 1, prob = probs[x,]))

x_marg <- x_marg - 1
y_marg <- y_marg - 1

library(tidyverse)
expand.cells <- function(cells, passage_time, b_s, d_s, b_r, d_r, mu)
{
  num_barcodes <- nrow(cells)
  # expand all currently resistant cells first according to Durrett (no mutation)
  resistant_cells <-
    sapply(cells[, 2], function(x){
      z <- rbinom(1, x, 1 - alpha(b_r, d_r, passage_time))
      sum(z + rgeom(z, 1 - beta(b_r, d_r, passage_time)))
    })
  cells[, 2] <- 0
  
  # Gillespie expansion of sensitive cells with mutation
  for(i in 1:num_barcodes)
  {
    curr_time <- 0
    while(curr_time < passage_time)
    {
      if(sum(cells[i,]) == 0) break
      # get current rate and time until next event
      rate <- cells[i,] %*% c(b_s + d_s, b_r + d_r)
      next_time <- rexp(1, rate)
      # update current time
      curr_time <- curr_time + next_time
      if(curr_time > passage_time) break
      
      # choose next event
      next_event <- rmultinom(1, 1, c(cells[i,1] * b_s, # sensitive birth and no mutation
                                      cells[i,1] * mu, # sensitive birth and mutation
                                      cells[i,1] * d_s, # sensitive death
                                      cells[i,2] * b_r, # res birth
                                      cells[i,2] * d_r)) # res death
      # update next event
      cells[i,1] <- cells[i,1] + next_event[1,1] - next_event[3,1]
      cells[i,2] <- cells[i,2] + next_event[2,1] + next_event[4,1] - next_event[5,1]
    }
  }
  # Add in the cells that entered the passage as resistant
  cells[,2] <- cells[,2] + resistant_cells
  return(cells)
}


b_1 <- 1
d_1 <- 0.2
b_2 <- 1.1
d_2 <- 0.3
mu <- 0.01
N <- 10000
rho <- 0
Time <- 4

bp <- expand.cells(matrix(c(rep(1, N), rep(0, N)), ncol = 2), 5, b_1, d_1, b_2, d_2, mu)

plot(ecdf(bp[,2]), pch = "")
lines(ecdf(y_marg), pch = "", col = "red")

2^(13*2)
2^13
