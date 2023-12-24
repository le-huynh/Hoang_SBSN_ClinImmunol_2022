title 'Prior information p1 ~ uniform(0, p2); cutoff_outlier.csv';

PROC import datafile="/home/u59121122/cutoff_outlier.csv"
DBMS=csv out=Data replace;
RUN; 


PROC MCMC 
	data=Data outpost=Dataoutput 
		nbi=500000 
		nmc=1000000
		thin=100
		seed=1
	/*	statistics(alpha=0.2) /*alpha=0.01-> display 99%HDI*/
		monitor=(p1 p2 cp I w); 
PARMS cp1 cp2 p1 p2 w I; 
prior cp1 ~ uniform(1,15); 
prior cp2 ~ normal(5,sd=1); 
hyperprior I ~ beta(1,1); 
prior w ~ binary(I); 
cp = w*cp1 + (1-w)*cp2; 
prior p2 ~ uniform(0.7, 1);
prior p1 ~ uniform(0, p2);
p = (AI<=cp)*p1 + (AI>cp)*p2; 
model Y ~ binary(p);
RUN;


/* Prior specification */
/* prior p1 ~ uniform(0, 1); */
/* prior p2 ~ uniform(p1, 1);  */