#---
# plot_boxplot_noHC.R
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
# figures/boxplot_noHC.pdf
# figures/boxplot_noHC.png
#---

library(here)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(robustbase)
library(lehuynh)
library(cowplot)

# data #--------------------------------
var <- c("NPSLE", "SLE", "VM", "MS")

data <- read.csv(here("data", "SBSN.csv")) %>%
          filter(disease != "HC") %>%
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

p_value <- summary(lmrob_res)$coefficients[,"Pr(>|t|)"][2:4]
pdata <- data.frame(group1 = rep("NPSLE", 3),
                    group2 = c("SLE", "VM", "MS"),
                    p = p_value)

# infor #----------------------------
title <- labs(x = "Disease",
              y = "Anti-SBSN antibodies relative concentration (SRC)")

xlabel <- scale_x_discrete(limits = var,
                           labels = c("NPSLE" = expression(atop(NPSLE, "(n = 35)")),
                                      "SLE"   = expression(atop(SLE, "(n = 34)")),
                                      "VM"    = expression(atop(VM, "(n = 20)")),
                                      "MS"    = expression(atop(MS, "(n = 16)"))))

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

y_position <- c(7.5, 9.0, 10.5)
p_val <- stat_pvalue_manual(pdata, 
                            y.position = y_position,
                            label = "p = {round(p, 5)}")

ciSLE <- annotate("text", 
                  x = 1.5, 
                  y = 7.2, 
                  label = "(-0.755, 0.178)",
                  size = 3.75)
ciVM <- annotate("text", 
                 x = 2.0, 
                 y = 8.7, 
                 label = "(-1.132, -0.148)")
ciMS <- annotate("text", 
                 x = 2.5, 
                 y = 10.2, 
                 label = "(-1.537, -0.037)")

height_mm = (240/3)*2

# plot without HC #--------------------
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
          title +
          xlabel +
          lehuynh_theme()

fig <- ggdraw(add_sub(fig, "Fig.1"))

ggsave_elsevier("figures/boxplot_noHC.pdf",
                fig,
                width = "one_half_column",
                height = height_mm)

ggsave_elsevier("figures/boxplot_noHC.png",
                fig,
                width = "one_half_column",
                height = height_mm)

