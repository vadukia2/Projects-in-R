

N <- 100000
counter <- 0
  
for (i in rnorm(N)) { 
  if (i > -1 & i < 1) {
    counter <- counter + 1
  }
}

answer <- counter/ N 
answer

# The law of large numbers, in probability and statistics, states that as a sample size grows, its mean gets closer to the average of the whole population.
#In a financial context, the law of large numbers indicates that a large entity which is growing rapidly cannot maintain that growth pace forever
# The above code just illustrates a example of law of large numbers when applied to  a normally distributed data of random number, the higher the number of observation lying between 1 and -1.
#As per law of large number 68% of the distribution should lie between 1 and -1.
