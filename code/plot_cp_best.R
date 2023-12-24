#---
# plot_cp_BEST.R
#
# This Rscript:
# * plot posterior distributions of cp, p1, p2 
# * save as pdf, tiff, png --> follow Elsevier instruction
#
# Dependencies...
# final_cutoff/cp_VEleni_final.csv
#
# Produces...
# results/figures/cp_HPDI.pdf
# results/figures/cp_HPDI.png
#---

library(here)
library(BEST)

data = read.csv(here("final_cutoff/cp_VEleni_final.csv"))

cp_title = "Cutoff"
p1_title = "1 - NPV"
p2_title = "PPV"

prob = 0.95

convert_mm_in = function(x) {x/25.4}

height_mm = 240/3
height_in = convert_mm_in(height_mm)
width_full_in      = convert_mm_in(190)
width_1half_col_in = convert_mm_in(140)
width_1col_in      = convert_mm_in(90)

cex = 1
cexlab = 1.1

# use package BEST #------------------------------------------------------------
source(here("code", "func_plotPost.R"))

## pdf #-----------------
pdf("figures/cp_HPDI.pdf",
    width = width_full_in,
    height = height_in)

par(mfrow = c(1, 3))

rv_plotPost(data$cp,
         credMass = prob,
         xlab = cp_title,
         cex = cex,
         cex.lab = cexlab,
         HDItextPlace = 1)
abline(v = mean(data$cp), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

rv_plotPost(data$p1,
         credMass = prob,
         xlab = p1_title,
         cex = cex,
         cex.lab = cexlab)
abline(v = mean(data$p1), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

rv_plotPost(data$p2,
         credMass = prob,
         xlab = p2_title,
         cex = cex,
         cex.lab = cexlab)
abline(v = mean(data$p2), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

dev.off()

## png #----------------------
pdf("figures/cp_HPDI.png",
    width = width_full_in,
    height = height_in)

par(mfrow = c(1, 3))

rv_plotPost(data$cp,
            credMass = prob,
            xlab = cp_title,
            cex = cex,
            cex.lab = cexlab,
            HDItextPlace = 1)
abline(v = mean(data$cp), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

rv_plotPost(data$p1,
            credMass = prob,
            xlab = p1_title,
            cex = cex,
            cex.lab = cexlab)
abline(v = mean(data$p1), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

rv_plotPost(data$p2,
            credMass = prob,
            xlab = p2_title,
            cex = cex,
            cex.lab = cexlab)
abline(v = mean(data$p2), 
       col = "darkred", 
       lty = "dotted",
       lwd = 2)

dev.off()


