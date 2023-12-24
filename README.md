# Measurement of anti-suprabasin antibodies, multiple cytokines and chemokines as potential predictive biomarkers for neuropsychiatric systemic lupus erythematosus

Trang T T Hoang, Kunihiro Ichinose, Shimpei Morimoto, Kaori Furukawa, Ly H T Le, Atsushi Kawakami  

DOI: [10.1016/j.clim.2022.108980](https://doi.org/10.1016/j.clim.2022.108980)  

Citation:  
```
Hoang, T. T. T., Ichinose, K., Morimoto, S., Furukawa, K., Le-Huynh, T.-L., Kawakami, A. (2022). Measurement of anti‑suprabasin antibodies, multiple cytokines and chemokines as potential predictive biomarkers for neuropsychiatric systemic lupus erythematosus. Clinical Immunology, 237(March), 1–8.
```

<img align="left" alt="R" width="26px" src="https://github.com/le-huynh/lehuynh.rbind.io/blob/main/static/img/loglo_info.png?raw=true" /> [More info](https://lehuynh.rbind.io/project/proj_npsle/)


-------------------

This repo includes all data, code, results of Bayesian data analysis, and documents related to SBSN data.

### Repo Overview

	project
	|- README.md       # the top level description of content (this doc)
	|
	|- manuscript/
	| |- manuscript.Rmd    # executable Rmarkdown for Bayesian analysis
	| |- manuscript.pdf    # PDF version of *.Rmd file
	| |- SBSN.bib          # BibTeX formatted references
	| +- other files       # optional files utilized for exporting the .Rmd file to the .pdf format (safe for deletion)
	|
	|- data           # raw and primary data, are not changed once created
	| |- SBSN.csv                          # raw data, will not be altered
	| |- Full SBSN 2021.6.8.xlsx           # raw data, will not be altered
	| |- code_book.md             # note about raw data
	| |- Analysing note.docx      # note about raw data
	| +- cp/     # cleaned data, related to Cutoff analysis
	|   |- cutoff_.csv            # data for Cutoff analysis
	|   +- cp_.csv                # posterior data (downloaded from SAS)
	|
	|- final_cutoff/    # final code, result, posterior data for Cutoff analysis in SAS
	|
	|- code/          # any programmatic code
	|
	|- results        # all output from workflows and analyses
	| |- tables/      # text version of tables to be rendered with kable in R
	| |- figures/     # graphs, likely designated for manuscript figures
	| +- pictures/    # diagrams, images, and other non-graph graphics
	|
	|- notebook/      # exploratory data analysis for this study
	|
	+- Makefile       # executable Makefile for this study

