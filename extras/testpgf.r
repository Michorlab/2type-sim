source("~/Dropbox/michor/projects/barcode_passaging_experiment/functions.r")

library(tidyverse)
expand.cells <- function(cells, passage_time, b_s, d_s, b_r, d_r, mu)
{
  b_s <- b_s + mu
  mu <- mu / (b_s + mu)
  num_barcodes <- nrow(cells)
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
      next_event <- rmultinom(1, 1, c(cells[i,1] * b_s * (1-mu), # sensitive birth and no mutation
                                      cells[i,1] * b_s * mu, # sensitive birth and mutation
                                      cells[i,1] * d_s, # sensitive death
                                      cells[i,2] * b_r, # res birth
                                      cells[i,2] * d_r)) # res death
      # update next event
      cells[i,1] <- cells[i,1] + next_event[1,1] - next_event[3,1]
      cells[i,2] <- cells[i,2] + next_event[2,1] + next_event[4,1] - next_event[5,1]
    }
  }
  return(cells)
}


b_1 <- 1
d_1 <- 0.2
b_2 <- 1.1
d_2 <- 0.3
mu <- 0.1
domain <- 10
rho <- 0
Time <- 6

pdf <- p2type(Time, 1, d_1, mu, b_2, d_2, domain)

# Generate random numbers
N <- 5000

bp <- expand.cells(matrix(c(rep(1, N), rep(0, N)), ncol = 2), Time, b_1, d_1, b_2, d_2, mu)


plot(ecdf(bp[,1]), pch = "")
lines(cumsum(rowSums(pdf)), col = "red")

plot(ecdf(bp[,2]), pch = "")
lines(cumsum(colSums(pdf)), col = "red")
