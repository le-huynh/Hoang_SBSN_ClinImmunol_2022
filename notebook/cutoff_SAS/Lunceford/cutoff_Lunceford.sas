PROC import datafile="/home/u59121122/cutoff_data.csv"
DBMS=csv out=Data replace;
RUN; 

proc mcmc 
	data=Data 
	outpost=aout
	nmc=10000 
	seed=1 ;
parms alpha bet mu s2;
prior alpha ~ normal(0, sd=100);
prior bet ~ normal(0, sd=100);
prior mu ~ normal(0, sd=100);
prior s2 ~ igamma(shape=3, scale=2);
model AI ~ normal(mu, var=s2);
lambda = alpha + bet * AI;
model Y ~ binary(logistic(lambda));
run;


/* Calculate  Patient Prevalence Profile */
data est;
set aout;
call streaminit(10710);
s = rand("normal", mu, sqrt(s2));
prevc = (s > &c);
run;


/* Calculate PPV */
data est;
set aout;
call streaminit(10710);
s = &c - 1;
do while (s < &c);
s = rand("normal", mu, sqrt(s2));
end;
p = logistic(alpha + bet * S);
ppvC = pdf("bernoulli", 1, p);
run;

/* Calculate NPV */
data est;
set aout;
call streaminit(10710);
s = &c + 1;
do while (s > &c);
s = rand("normal", mu, sqrt(s2));
end;
p = logistic(alpha + bet * S);
npvC = pdf("bernoulli", 0, p);
run;
