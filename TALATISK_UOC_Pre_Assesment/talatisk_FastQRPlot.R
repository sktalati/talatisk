#Author: Snehal Talati 
#Description: R-script to create the plots
#Usage: Please make sure the file name is the same as listed in the script "R_Data_UOC.txt"
#Version: 1.0

X <- read.table("R_Data_UOC.txt", header=TRUE, sep='\t')
library(ggplot2)
ggplot(X, aes(x=Cycle, y=Avg, ymin=Avg-Stdev, ymax=Avg+Stdev)) +
geom_point()+geom_linerange() + 
scale_x_continuous(name="Number of Cycles",breaks=c(seq(0,151,by=10))) +
geom_errorbar(width=0.1) + 
scale_y_continuous(name="Average Quality Score", limits=c(0,45))
ggsave(file="FastQQuality_Plot.pdf")