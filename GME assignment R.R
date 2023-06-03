library(lubridate)
library(gridExtra)
library(ggplot2)
library(zoo)
library(officer)
library(openxlsx)
library(data.table)
library(psych) 


b <- choose.files(default="", caption="Select GME interest google trend file",
                  multi=FALSE, filters=Filters,
                  index=nrow(Filters))
Trend <- read.csv(b, skip=2,header=TRUE)

c <- choose.files(default="", caption="Select GME stock prices file",
                  multi=FALSE, filters=Filters,
                  index=nrow(Filters))
GME <- read.csv (c)

GME <- GME[, c("Date", "Adj.Close")]
GME <- transform(GME,yearmon=as.yearmon(Date))
GMEsub <- aggregate(GME$Adj.Close~GME$yearmon,FUN=mean)
names(GMEsub)[1] <- "yearmon"
names(GMEsub)[2] <- "Adj.Close"

names(Trend)[names(Trend)=="game.stocks...United.States."] <- "GME"
Trend <- transform(Trend,yearmon=as.yearmon(Month))
Trend <- subset(Trend, GME > 0)

df <- merge(GMEsub,Trend, by="yearmon")

Line <- ggplot(df, aes(x=yearmon))+
  geom_line( aes(y=GME,colour="Google trend"))+
  geom_line( aes(y=Adj.Close, colour="Stock price"))+
  labs(x="Date", y="Google trend", colour="Legend:") +
  scale_y_continuous(sec.axis = sec_axis(~.*1,name="Stock Price"))+
  ggtitle("Relation bewteen GME's stock price and google trend") +
  theme(legend.key=element_rect(fill="white"),
        panel.background=element_rect(fill=NULL,colour="black"),
        panel.grid.minor = element_blank(),
        legend.position="right")


Scatter <- ggplot(df, aes(Adj.Close,GME)) + geom_point(color="red") +   
  labs(y="Google Trend",x="Stock Price") + 
  theme(panel.border = element_rect(colour = "black", fill=NA),
    panel.grid.minor = element_blank()) +
ggtitle("Scatterplot of GME stock price and google trend")

grid.arrange(Scatter, Line, nrow=2)  

df1 <- df[,c("Adj.Close","GME")]
df1cor <- corr.test(df$Adj.Close, df$GME, method = "pearson")
pval <- df1cor$p
pval <- round(pval, digits=5)
cval <- df1cor$r
cval <- round(cval, digits=5)

val <- rbind(pval,cval)
row.names(val)[1] <- "Correlation" 
row.names(val)[2] <- "P-value"

write.csv(val,file="correlation.csv")


df$StockLagged <- shift(df$Adj.Close,1,type="lag")
df$StockPerChange <- (df$Adj.Close-df$StockLagged)/df$StockLagged

df$TrendLagged <- shift(df$GME,1,type="lag")
df$TrendPerChange <- (df$GME-df$TrendLagged)/df$TrendLagged

df2 <- df[,c("StockPerChange","TrendPerChange")]
df2cor <- corr.test(df2$StockPerChange, df2$TrendPerChange, method = "pearson")
perpval <- df2cor$p
perpval <- round(perpval, digits=5)
percval <- df2cor$r
percval <- round(percval, digits=5)

perval <- rbind(perpval,percval)
row.names(perval)[1] <- "Correlation" 
row.names(perval)[2] <- "P-value" 

write.csv(perval, file="percentchange corr.csv")



