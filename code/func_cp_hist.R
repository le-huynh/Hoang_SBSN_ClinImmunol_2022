#---
# func_cp_hist.R
#
# This Rscript:
# A function to plot posterior distributions of cp, p1, p2 (with histogram)
#
# Dependencies...
#
# Produces...
#
#---
library(ggplot2)
library(lehuynh)

cp_hist = function(data, 
                  para,
                  xtitle,
                  ytitle = "Density",
                  histbin = 0.2,
                  histcolor = "gray68",
                  densize = 0.9,
                  dencolor = "black",
                  dx = c(0.01, 0.01),
                  ...)
{fig = ggplot(data, aes(x=para)) + 
          # histogram
          geom_histogram(aes(y = ..density..),
                         binwidth = histbin,
                         color = histcolor,
                         fill = "white") +
          # add mean line
          geom_vline(aes(xintercept=mean(para)), 
                     color = "red",
                     size = 1) +
          # add density line
          geom_density(size = densize,
                       color = dencolor) + 
          labs(x = xtitle,
               y = ytitle) + 
          xlim(min(para) - 0.025, max(para) + 0.025) +
          scale_y_continuous(expand = expansion(mult = dx)) +
          lehuynh_theme()
fig
}

