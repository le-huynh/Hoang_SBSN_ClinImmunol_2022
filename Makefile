# Rule
# target : prerequisite1 prerequisite2 prerequisite3
#	(tab)recipe

.PHONY: all clean

################################################################################
# 
# Part 1: Data for data analysis
# 
# Run scripts to generate dataset for data analysis
# 
################################################################################

#data/process/data_name.csv: \
#code/get_data_name.R\
#data/raw/data_name.csv
#	Rscript code/get_data_name.R


################################################################################
# 
# Part 2: Formal data analysis
# 
# Run scripts to fit models, etc.
# 
################################################################################

#data/RDSmodel/model_name.rds: \
#code/bayes_model.R\
#code/get_tidy_data.R\
#data/process/data_name.csv
#	Rscript code/bayes_model.R


################################################################################
# 
# Part 3: Figure and table generation
# 
# Run scripts to generate figures
# 
################################################################################

figures/cp_hist_black.pdf figures/cp_hist_black.png: \
code/plot_cp_black.R\
code/func_cp_hist.R\
final_cutoff/cp_VEleni_final.csv
	Rscript code/plot_cp_black.R

figures/cp_HPDI.pdf figures/cp_HPDI.png: \
code/plot_cp_best.R\
code/func_plotPost.R\
final_cutoff/cp_VEleni_final.csv
	Rscript code/plot_cp_best.R

figures/boxplot_noHC.pdf figures/boxplot_noHC.png: \
code/plot_boxplot_noHC.R\
data/SBSN.csv
	Rscript code/plot_boxplot_noHC.R

figures/boxplot_HC.pdf figures/boxplot_HC.png: \
code/plot_boxplot_HC.R\
data/SBSN.csv
	Rscript code/plot_boxplot_HC.R

################################################################################
# 
# Part 4: Pull it all together
# 
# Render the manuscript
# 
################################################################################
manuscript/manuscript.pdf: \
manuscript/manuscript.Rmd\
final_cutoff/cp_VEleni_final.csv\
manuscript/SBSN.bib\
manuscript/elsevier-harvard.csl
	Rscript -e 'rmarkdown::render("$<")'


