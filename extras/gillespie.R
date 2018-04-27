# 2-type Gillespie algorithm
gillespie <- function(t, alpha1, beta1, nu, alpha2, beta2, ancestors)
{
  curr_time <- 0
  z <- c(ancestors, 0)
  rate <- z[1] * (alpha1 + beta1 + nu) + z[2] * (alpha2 + beta2)
  while(curr_time < t & sum(z) > 0)
  {
    curr_time <- curr_time + rexp(1, rate)
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
    else if(u <= z[1] * (alpha1 + beta1 + nu) + z[1] * alpha2)
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


#system.time(gillespie(10, 1.0, 0.5, 0.05, 1.1, 0.5, 1))
#system.time(p2type(10, 0.35, 0.05, 0.05, 0.4, 0.05, 1, 9, threads = 4))
x <- p2type(10, 0.35, 0.05, 0.15, 0.4, 0.05, 1, 10, threads = 4)
gillespie(10, 0.35, 0.05, 0.05, 0.4, 0.05, 1)
y <- t(replicate(1000, gillespie(10, 0.35, 0.05, 0.05, 0.4, 0.05, 1)))

x[x<0] <- 0

library(tidyverse)
x<- x[1:32,1:32]
dimnames(x) <- list(X = 0:(nrow(x)-1), Y = 0:(ncol(x) - 1))
xtab <- as.data.frame(as.table(x))

xtab %>% ggplot(aes(X, Y, fill = log(Freq))) + geom_tile()
