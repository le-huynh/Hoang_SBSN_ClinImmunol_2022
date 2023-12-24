library(tidyverse)
library(pgirmess)
library(readxl)
library(psych)
library(PMCMRplus)
library(table1)
library(compareGroups)
library(ggpubr)
library(rstatix)
library(simpleboot)
library(boot)
library(gmodels)
library(car)
library(expss)
library(cutpointr)
library(plyr)

dir.data <- "../../mail/210615/data/rec"
fn.data <- "Full SBSN 2021.6.8 .xlsx"

Full_SBSN_2021_6_8_ <- read_excel(sprintf("%s/%s", dir.data, fn.data),na = "NA")
data1 <-Full_SBSN_2021_6_8_
# str(data1)


# change class ---------------
data1$sm <-as.numeric(Full_SBSN_2021_6_8_$sm)
data1$csfil6 <-as.numeric(Full_SBSN_2021_6_8_$csfil6)
data1$iggin <-as.numeric(Full_SBSN_2021_6_8_$iggin)
data1$disease2 <- factor(Full_SBSN_2021_6_8_$disease,levels = c("SLE","VM","MS","HC","NPSLE"),labels = c("SLE/VM/MS/HC","SLE/VM/MS/HC","SLE/VM/MS/HC","SLE/VM/MS/HC","NPSLE"))
# data1$APS <- as.character(Full_SBSN_2021_6_8_$APS)
# data1$LN <- as.character(Full_SBSN_2021_6_8_$LN)


data1$gender <- factor(Full_SBSN_2021_6_8_$gender,
                    levels = c("F","M"),
                    labels = c("Female", "Male"))
data1$APS <- factor(Full_SBSN_2021_6_8_$APS,
                       levels = c(0,1),
                       labels = c("Negative", "Positive"))
data1$LN <- factor(Full_SBSN_2021_6_8_$LN,
                    levels = c(0,1),
                    labels = c("Negative", "Positive"))
data1$sympclass <- factor(Full_SBSN_2021_6_8_$sympclass,
                    levels = c(0,1),
                    labels = c("Focal symptom", "Diffuse symptom"))

data1$disease<- 
  factor(
    Full_SBSN_2021_6_8_$disease,
    levels=c("NPSLE","SLE","VM","MS","HC"),
    ordered=TRUE
    )


# omit NA values
na.omit(data1) # changes nothing.

# measure distribution of data--------------

# Why did you use this test?
a<-shapiro_test(data1,AI0.005, logAI0.005,AI0.01, age, dd, sledai,
                dsdna,sm,csfil6, iggin,c3,c4,EGF,EOTA, FGF2, FLT3L, 
                FRAC, GCSG, GMCSF, GRO,
                IFNg, IL10, IL12p40, IL12p70, IL13, IL15, IL17, IL1a, 
                IL1b, IL1ra, IL2, IL3, IL4, IL5, IL6, IL7, 
                IL8, IL9, INFa2, IP10, MCP1, MCP3, MDC, MIP1a, MIP1b, TGFa, TNFa, 
                TNFb, VEGF,sCD40L, vars=NULL)
view(a)

# patient profiles---------------


data1 <- 
  expss::apply_labels(
    data1, 
    APS= "APS, positive", LN= "LN, positive",age="Age",gender="Gender",
    dsdna="anti-dsDNA antibodies(U/ml)", sm="anti-Sm antibodies (U/ml)",
    dd= "Disease duration,year", sledai= "SELENA-SLEDAI, score",
    c3="C3 (mg/dl)", c4="C4(mg/dl)", csfil6= "CSF IL-6(pg/ml)",
    antipin="Anti ribosome P antibodies(index)",iggin="IgG index"
    )

# packege expss for apply labels, not change name of variables
res <-
  createTable(
    compareGroups(
      disease~age + gender+ dd + sledai+dsdna+sm+APS+LN +csfil6+ c3+c4 +antipin+iggin,
      data=data1,
      method=c(age=2, dd=2, sledai=2, dsdna=2, c3=1, csfil6=2, sm=2,iggin=2,c4=2),
      Q1=0.25, Q3=0.75),show.p.trend=F, hide.no="Negative",
    hide=c(gender="Male")
    )
# can show pair p values by add show.p.mul=T to creatTable.
print(res,header.labels = c(p.overall="p-value"))
# export to word, stored in document file in computer
export2word(
  res,
  file = 'table1.docx', # Setting dir. does not work. 
  header.labels = c(p.overall="p-value")
  )

s <- 
  data1 %>% 
  filter(
    antipin=="Positive"| 
      antipin=="Negative"
    )

CrossTable(s$disease,s$antipin,prop.c=F,prop.r=T,prop.t=F,prop.chisq=F,chisq=T,fisher = T)
# clinical symptom in NPSLE
symp <- createTable(compareGroups(disease~s1+s2+sympclass,data=data1))
print(symp)
export2word(symp,file = 'table2.docx')

# boxplot for SBSN AI0.005 comparision between groups
data1 <- 
  data1[!is.na(data1$disease),]

a<- 
  ggplot(
    data1, aes(x=disease, y=AI0.005,fill=disease)
    )+ 
  geom_boxplot(
    outlier.colour = "red"
    )+ 
  scale_fill_brewer(
    palette="Pastel1"
    )+
  theme_bw()+
  theme_classic()+ 
  labs(
    x="Disease", y=" Antibody Index"
    )

a <- a + geom_dotplot(binaxis='y', stackdir='center', dotsize=1, fill="blue")+scale_shape_manual(values=c(18)) 
a
# boxplot without HC group
data2 <- 
  data1 %>% 
  filter(
    disease=="NPSLE"| disease=="SLE"|disease=="MS"|disease=="VM"
    )
b <- ggplot(data2, aes(x=disease, y=AI0.005,fill=disease))+ 
  geom_boxplot(outlier.colour = "red")+ scale_fill_brewer(palette="Pastel1")+
  theme_bw()+theme_classic()+ labs(x="Disease", y=" Antibody Index")
b <- b + geom_dotplot(binaxis='y', stackdir='center', dotsize=1, fill="blue")+scale_shape_manual(values=c(18)) 
b
#making errorbar with the ggplot2

data_summary <- 
  function(data, varname, groupnames){
    # require(plyr)
    summary_func <- 
      function(x, col){
        c(mean = mean(x[[col]], na.rm=TRUE),
          sd = sd(x[[col]], na.rm=TRUE)
          )
        }
  
    data_sum <-
      ddply(
        data, groupnames, .fun=summary_func,
        varname
        )
    data_sum <- rename(data_sum, c("mean" = varname))
    return(data_sum)
    }

sd1 <- 
  data_summary(
    data1, varname="AI0.005", 
    groupnames=c("disease")
    )

# sd1$disease <-  ## Changes Nothing.
#   as.factor(sd1$disease)

p <- ggplot(sd1, aes(x=disease, y=AI0.005,fill=disease)) + 
  geom_bar(stat="identity", color="black", position=position_dodge(),width = 0.5) +
   geom_errorbar(aes(ymin=AI0.005,ymax=AI0.005+sd),position = position_dodge(0.9),width=.2)
                
p+scale_fill_brewer(palette="Pastel1") + theme_bw()+theme_classic()+ labs(x= NULL,y=" Antibody Index")
# many-to-one Van der Waerden'test, without HC group 
vanWaerdenTest(AI0.005 ~ disease, data = data2)
van <-vanWaerdenManyOneTest(AI0.005 ~ disease, data = data2,
                         p.adjust.method = "holm")
summary(van)
# correlation R and p value
library(Hmisc)
data4 <- data1 %>% filter(disease=="NPSLE"|disease=="SLE")
na.omit(data4)
correlations <- rcorr(as.matrix(data4),type = c("pearson","spearman"))
correlations$r
correlations$P

#2nd way to visualize the correlation efficient in NPSLE group
library(corrplot)

corrplot(correlations$r, type="upper",  tl.col = "blue",tl.cex = 0.5,
         p.mat = correlations$P, sig.level = 0.05, insig = "blank")
# ROC curve and cutoff point by bootstrap method
library(cutpointr)
cut <-data1 %>% filter(disease=="NPSLE"| disease=="SLE")
view(cut)
set.seed(12)
cp <-cutpointr(cut,AI0.005,disease,subgroup = NULL, boot_runs = 10000)
cp
plot(cp)
# The returned object has the additional column boot which is a nested tibble that includes the cutpoints per bootstrap sample along with the metric calculated using the function in metric and various default metrics. The metrics are suffixed by _b to indicate in-bag results or _oob to indicate out-of-bag results:
cp$boot
summary(cp)
plot(cp)+theme_bw()+theme_classic()
plot_cut_boot(cp)+theme_classic()
plot_sensitivity_specificity(cp)+theme_bw()+theme_classic()
plot_roc(cp)
# by Bootstraps for correlation between AI and sCD40L
library(boot)
af <- subset(data4,select=c(AI0.005,sCD40L))
# write the function getcor, as for everytime using bootstrap for estimate correlation
getcor <-function(x) {
    return(cor(x[,"AI0.005"],x[,"sCD40L"], method="spearman"))
      }
result <- boot(af,getcor, R=1000, stype = "i")
result
boot.ci(result,type="bca")
#visulaize of correlation efficient between SBSN and sCD40L

gcsg <- ggplot(data4,aes(y=K$AI0.005,x=K$GCSG))
gcsg +geom_point(colour="blue")+stat_smooth(method=lm,level=0.99, colour="red")+ labs(x="GCSG",y="AI")+ theme_bw()+theme_classic()
#compare cytokine profile NPSLE and SLE

Cy <-createTable(compareGroups(disease~age+dd+sledai+ dsdna+sm+c3+c4+csfil6+iggin+
                                 EGF + EOTA+ FGF2 +FLT3L+FRAC + 
                                 GCSG + GMCSF+GRO  +IFNg+IL10  +
                                 IL12p40+IL12p70 +IL13 + IL15+  
                                 IL17+ IL1a+ IL1b+ IL1ra+ IL2 + IL3 +IL4+ 
                                 IL5 + IL6 +IL7+ IL8 +IL9+ INFa2 + 
                                 IP10+ MCP1+MCP3 +MDC+MIP1a+MIP1b+TGFa+ 
                                 TNFa+TNFb+ VEGF+ sCD40L,data=dataAs,max.ylev = 4,
                                 data=data4, method=c(age=2,dd=2,sledai=2,dsdna=2,sm=2, c3=1,c4=2,
                                                                                 csfil6=2,iggin=2,EGF=2,EOTA=2, FGF2=2, FLT3L=2, FRAC=2,GCSG=2,
                                                                                 GMCSF=2,GRO=2, IFNg=2,IL10=2,IL12p40=2,IL12p70=2,
                                                                                 IL13=2, IL15=2, IL17=2, IL1a=2,IL1b=2,IL1ra=2, 
                                                                                 IL2=2,IL3=2,IL4=2, IL5=2, IL6=2, IL7=2, IL8=2,
                                                                                 IL9=2,INFa2=2, IP10=2, MCP1=2,MCP3=2,MDC=2,
                                                                                 MIP1a=2,MIP1b=2,TGFa=2,TNFa=2,TNFb=2, VEGF=2,sCD40L=2),
                                       Q1=0.25, Q3=0.75),show.p.trend=F, hide.no="Negative")
print(Cy,header.labels = c(p.overall="p-value"))


