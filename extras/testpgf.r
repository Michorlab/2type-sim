source("~/Dropbox/michor/projects/barcode_passaging_experiment/functions.r")

library(tidyverse)
expand.cells <- function(cells, passage_time, b_1, d_1, b_2, d_2, mu)
{
  num_barcodes <- nrow(cells)
  # Gillespie expansion of sensitive cells with mutation
  for(i in 1:num_barcodes)
  {
    curr_time <- 0
    while(curr_time < passage_time)
    {
      if(sum(cells[i,]) == 0) break
      # get current rate and time until next event
      rate <- cells[i,] %*% c(b_1 + d_1 + mu, b_2 + d_2)
      next_time <- rexp(1, rate)
      # update current time
      curr_time <- curr_time + next_time
      if(curr_time > passage_time) break
      
      # choose next event
      next_event <- rmultinom(1, 1, c(cells[i,1] * b_1, # sensitive birth and no mutation
                                      cells[i,1] * mu, # sensitive birth and mutation
                                      cells[i,1] * d_1, # sensitive death
                                      cells[i,2] * b_2, # res birth
                                      cells[i,2] * d_2)) # res death
      # update next event
      #cells[i,1] <- cells[i,1] + next_event[1,1] - next_event[3,1]
      cells[i,1] <- cells[i,1] + next_event[1,1] - next_event[2,1] - next_event[3,1]
      cells[i,2] <- cells[i,2] + next_event[2,1] + next_event[4,1] - next_event[5,1]
    }
  }
  return(cells)
}


b_1 <- 1
d_1 <- 0.4
b_2 <- 1.1
d_2 <- 0.3
mu <- 0.1
domain <- 10
Time <- 5

pdf <- p2type(Time, 1, d_1, mu, b_2, d_2, domain)

# Generate random numbers
N <- 10000
bp <- expand.cells(matrix(c(rep(1, N), rep(0, N)), ncol = 2), Time, b_1, d_1, b_2, d_2, mu)


plot(ecdf(bp[,1]), pch = "")
lines(0:(ncol(pdf)-1), cumsum(rowSums(pdf)), col = "red")

plot(ecdf(bp[,2]), pch = "")
lines(0:(nrow(pdf)-1), cumsum(colSums(pdf)), col = "red")


# Test with means
sum(pdf)
x <- rowSums(pdf)
sum(x * 0:(length(x)-1))
exp((b_1 - d_1 - mu) * Time)

y <- colSums(pdf)
sum(y * 0:(length(y)-1))

mu * (exp((b_2 - d_2) * Time) - exp((b_1 - d_1 -mu) * Time)) / ((b_2 - d_2) - (b_1 - d_1 - mu))


