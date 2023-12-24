#---
# plot_cp_black.R
#
# This Rscript:
# * plot posterior distributions of cp, p1, p2 
# * save as pdf, tiff, png --> follow Elsevier instruction
#
# Dependencies...
# final_cutoff/cp_VEleni_final.csv
#
# Produces...
# results/figures/cp_hist_black.pdf
# results/figures/cp_hist_black.png
#---

library(here)
library(ggplot2)
library(cowplot)
library(lehuynh)

data = read.csv(here("final_cutoff/cp_VEleni_final.csv"))

cp_title = "Cutoff"
p1_title = "1 - NPV"
p2_title = "PPV"

height_mm = 240/3

# with histogram #--------------------------------------------------------------
source(here("code", "func_cp_hist.R"))

cp_h <- cp_hist(data = data,
                para = data$cp,
                xtitle = cp_title,
                densize = 0.5,
                histbin = 0.3)

p1_h <- cp_hist(data = data,
                para = data$p1,
                xtitle = p1_title,
                densize = 0.5,
                histbin = 0.015)

p2_h <- cp_hist(data = data,
                para = data$p2,
                xtitle = p2_title,
                densize = 0.5,
                histbin = 0.012)

plot_hist <- plot_grid(cp_h, p1_h, p2_h,
                       ncol = 3)
ggsave_elsevier("figures/cp_hist_black.pdf",
                plot = plot_hist,
                width = "full_page",
                height = height_mm)
ggsave_elsevier("figures/cp_hist_black.png",
                plot = plot_hist,
                width = "full_page",
                height = height_mm)

