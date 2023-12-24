#---
# plot_boxplot_HC.R
#
# This Rscript:
# generate boxplot for disease
# - boxplot
# - add sample size
# - add p-value, 95% CI
#
# Dependencies..
# data/SBSN.csv
#
# Produces...
# figures/boxplot_HC.pdf
# figures/boxplot_HC.png
#---

library(here)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(robustbase)
library(lehuynh)
library(cowplot)

# noHC #---------------------------------
## data #--------------------------------
var1 <- c("NPSLE", "SLE", "VM", "MS")

data1 <- read.csv(here("data", "SBSN.csv")) %>%
          filter(disease != "HC") %>%
          select(AI = AI0.005,
                 disease) %>%
          mutate(variable = factor(disease, 
                                   levels = var1))

## compute different means and p-value #---------------------
set.seed(5)
lmrob_res1 <- lmrob(AI ~ variable, data = data1)

ci1 <- confint(lmrob_res1, level = 0.95) %>%
          round(digits = 3)

p_value1 <- summary(lmrob_res1)$coefficients[,"Pr(>|t|)"][2:4]

# data #--------------------------------
var <- c("NPSLE", "SLE", "VM", "MS", "HC")

data <- read.csv(here("data", "SBSN.csv")) %>%
          select(AI = AI0.005,
                 disease) %>%
          mutate(variable = factor(disease, 
                                   levels = var))

nsamp <- data %>% count(disease)

# compute 95% CI and p-value #---------------------
set.seed(5)
lmrob_res <- lmrob(AI ~ variable, data = data)

ci <- confint(lmrob_res, level = 0.95) %>%
          round(digits = 3)

p_value <- summary(lmrob_res)$coefficients[,"Pr(>|t|)"][5]
pdata <- data.frame(group1 = rep("NPSLE", 4),
                    group2 = c("SLE", "VM", "MS", "HC"),
                    p = c(p_value1, p_value))

# infor #----------------------------
title <- labs(x = "Disease",
              y = "Anti-SBSN antibodies relative concentration (SRC)")

xlabel <- scale_x_discrete(limits = var,
                           labels = c("NPSLE" = expression(atop(NPSLE, "(n = 35)")),
                                      "SLE"   = expression(atop(SLE, "(n = 34)")),
                                      "VM"    = expression(atop(VM, "(n = 20)")),
                                      "MS"    = expression(atop(MS, "(n = 16)")),
                                      "HC"    = expression(atop(HC, "(n = 38)"))))

# The colorblind-friendly palette with black:
cbbPalette <- c(#"#000000", 
                "#E69F00", 
                "#56B4E9", 
                "#009E73", 
                #"#F0E442", 
                #"#0072B2", 
                "#D55E00", 
                "#CC79A7")

gr_fill <- scale_fill_manual(breaks = var, 
                             values = cbbPalette)

gr_col <- scale_color_manual(breaks = var, 
                             values = cbbPalette)

y_position <- c(7.5, 8.8, 10.1, 11.4)
p_val <- stat_pvalue_manual(pdata, 
                            y.position = y_position,
                            label = "p = {round(p, 5)}")

ciSLE <- annotate("text", 
                  x = 1.5, 
                  y = 7.2, 
                  label = "(-0.755, 0.178)",
                  size = 3.15)
ciVM <- annotate("text", 
                 x = 2, 
                 y = 8.5, 
                 label = "(-1.132, -0.148)",
                 size = 3.15)
ciMS <- annotate("text", 
                 x = 2.5,
                 y = 9.8, 
                 label = "(-1.537, -0.037)",
                 size = 3.15)
ciHC <- annotate("text", 
                 x = 3, 
                 y = 11.1, 
                 label = "(-0.240, 1.229)",
                 size = 3.15)

height_mm = (240/3)*2

# plot with HC #--------------------
fig <- data %>%
          ggplot(aes(x = disease, y = AI)) +
          geom_boxplot(aes(col = disease,
                           fill = disease,
                           alpha = 0.25),
                       outlier.color = "white",
                       outlier.fill = "white",
                       show.legend = FALSE) +
          geom_jitter(aes(col = disease), 
                      alpha = 0.75,
                      width = 0.125,
                      show.legend = FALSE) +
          gr_fill +
          gr_col +
          p_val +
          ciSLE +
          ciVM +
          ciMS +
          ciHC +
          title +
          xlabel +
          lehuynh_theme()

fig <- ggdraw(add_sub(fig, "Supplementary Fig. S1"))

ggsave_elsevier("figures/boxplot_HC.pdf",
                fig,
                width = "one_half_column",
                height = height_mm)

ggsave_elsevier("figures/boxplot_HC.png",
                fig,
                width = "one_half_column",
                height = height_mm)


