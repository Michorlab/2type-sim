# 2-type Gillespie algorithm
gillespie <- function(t, alpha1, beta1, nu, alpha2, beta2, ancestors, model = 2)
{
  curr_time <- 0
  z <- c(ancestors, 0)
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


#system.time(gillespie(10, 1.0, 0.5, 0.05, 1.1, 0.5, 1))
#system.time(p2type(10, 0.35, 0.05, 0.05, 0.4, 0.05, 1, 9, threads = 4))
x <- p2type2(1, 100, 1, 0.05, 0.15, 0.4, 0.05, 1, threads = 4)
y <- t(replicate(1000000, gillespie(1, 1, 0.05, 0.15, 0.4, 0.05, 1)))
x[1,1]
sum(y[,1] == 0 & y[,2] == 0) / 1000000

x <- p2type1(1, 100, 1, 0.05, 0.15, 0.4, 0.05, 1, threads = 4)
y <- t(replicate(1000000, gillespie(1, 1, 0.05, 0.15, 0.4, 0.05, 1, 1)))
x[1,1]
sum(rowSums(y) ==0) / 1000000



