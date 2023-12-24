# JAGS model for cutoff value

# packages #--------------------------------------------------------------------
library(here)
library(dplyr)
library(R2jags)

# DATA #------------------------------------------------------------------------
dat = read.csv(here("Data", "SBSN.csv"))
dat1 = dat %>% 
          select(AI = AI0.005, disease) %>%
          filter(disease == "NPSLE" | disease == "SLE") %>%
          mutate(Y = if_else(disease == "NPSLE", 1, 0))

dataList = list(Y = dat1$Y,
                AI = dat1$AI,
                n_obs = length(dat1$Y))

# MODEL #-----------------------------------------------------------------------
cutoff <- "model {
          
          # model
          for (i in 1:n_obs){
                    Y[i] ~ dbern(p)
                              ## failed to model step function
                    p <- (AI[i]<=cp)*p1 + (AI[i]>cp)*p2
                    cp <- w*cp1 + (1-w)*cp2
          }

          # priors
          p2 ~ dunif(p1, 1)
          p1 ~ dunif(0, 1)
          w ~ dbern(I)
          I ~ dbeta(1, 1)
          cp1 ~ dunif(1, 15)
          cp2 ~ dnorm(5, 1)

}"

writeLines(cutoff, con="cutoff_JAGS.txt" )

# Specify PRIOR #---------------------------------------------------------------

# INITIALIZE CHAIN #------------------------------------------------------------
# Let JAGS do it automatically...

# GENERATE CHAIN #--------------------------------------------------------------

# Make the same "random" choices each time this is run.
# This makes the Rmd file stable --> can comment on specific results.
set.seed(12345)   

paraList = c("p1",
             "p2",
             "cp1",
             "cp2",
             "w",
             "I")

n.iter = 10000
n.burnin = 5000
n.chains = 3
n.thin = 1

# Fit the model
cutoff_jags <- jags(data = dataList,
                  model.file = "cutoff_JAGS.txt",
                  parameters.to.save = paraList,
                  n.iter = n.iter,
                  n.burnin = n.burnin,
                  n.chains = n.chains,
                  n.thin = n.thin
                  # inits = inits
)

update(cutoff_jags, n.iter = 100000)

#' References
#' 1. [Understanding error messages in JAGS](https://www4.stat.ncsu.edu/~bjreich/BSMdata/errors.html)  
#' 2. [JAGS Version 3.4.0 user manual](https://ams206-winter18-01.courses.soe.ucsc.edu/system/files/attachments/jags-user-manual.pdf)  

