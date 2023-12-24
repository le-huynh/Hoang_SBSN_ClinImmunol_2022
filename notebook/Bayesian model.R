library(tidyverse)
library(readxl)
library(caret)
library(psych)
library(glmnet)
library(performance)
library(ROCR)
library(rstan)
library(brms)
library(tidybayes)

# data #-------------
Full_SBSN_2021_6_8_ <- read_excel(file.choose())
data1 <-Full_SBSN_2021_6_8_

data1$sm <-as.numeric(data1$sm)
data1$csfil6 <-as.numeric(data1$csfil6)
data1$iggin <-as.numeric(data1$iggin)
data1$disease2 <- factor(data1$disease2)
data1$APS <- as.character(data1$APS)
data1$LN <- as.character(data1$LN)

# variable selection 
data.SLE_NPSLE <- data1 %>% 
        dplyr::filter(disease=="NPSLE"|disease=="SLE") %>%
        dplyr::select(disease2,AI0.005, iggin,csfil6,APS,
                      EGF,EOTA,
                      FGF2,FLT3L,FRAC,GCSG,
                      GMCSF,GRO,IFNg,IL10,
                      IL12p40,IL12p70,IL13,IL15,
                      IL17,IL1a,IL1b,IL1ra,IL2, IL3, IL4, IL5,
                      IL6,IL7,IL8,IL9,
                      INFa2 ,IP10 ,MCP1,MCP3,
                      MDC,MIP1a,MIP1b,TGFa,
                      TNFa,TNFb ,VEGF,sCD40L)

data.SLE_NPSLE$APS <- as.numeric(as.character(data.SLE_NPSLE$APS))
data.SLE_NPSLE<- na.omit(data.SLE_NPSLE)

# build logistic regression #-------
# remove APS, FGF2, FRAC, GCSG, GRO, IFNg,IL12p40, IL15, IL17, IL13, IL7, MCP1,MDC,MIP1a,
logit <- glm(disease2 ~.-IL1a-TNFb- IL12p70 - IL13-IL1b-IL4- IL5- GMCSF-IL2
             - INFa2 - IL1ra
             - IP10 - MIP1b
             - APS -FGF2 - FRAC- GCSG -GRO 
             - IFNg -IL12p40 - IL15 - IL17 -IL13
             - IL7 -MCP1- MDC- MIP1a- MCP3,
             data=data.SLE_NPSLE,family ="binomial")

check_collinearity(logit)

# new dataset #---------
data.SLE_NPSLE.new <- data1 %>% 
        dplyr::filter(disease=="NPSLE"|disease=="SLE") %>%
        dplyr::select(
                disease2,AI0.005, iggin,csfil6,
                EGF,EOTA,
                FLT3L,IL10,
                IL3, 
                IL6,IL8,IL9,
                TGFa,
                TNFa,VEGF,sCD40L)

data.SLE_NPSLE.new <- na.omit(data.SLE_NPSLE.new)

# generic brms code for logistic regression using the Bernoulli likelihood 
fit1 <- brm(data = data.SLE_NPSLE.new, 
             family = binomial,
             disease2|trials(1)~1+ .,
             prior = c(prior(normal(0, 5), class = Intercept),
                       prior(normal(0, 5), class = b)),
            iter = 2500, warmup = 500, chains = 4, cores = 4,
            seed = 21)

print(fit1)

