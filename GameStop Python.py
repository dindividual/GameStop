import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import datetime as dr
import statistics as st

dfstk=pd.read_csv('GME weekly stock prices from yahoo.csv',parse_dates=True,index_col=0)

dfint=pd.read_csv('GME interest google trends.csv',skiprows=2)

#reformat date
dfint["Date"]=pd.to_datetime(dfint['Month'],format='%Y-%m')

#merge data
df1=pd.merge(dfstk,dfint,how="inner",left_index=True,right_on="Date")


df1=df1.rename(columns={'Adj Close':'stock prices'})
df1=df1.rename(columns={'game stocks: (United States)':'google trends'})
df1=df1.set_index("Date")
print

#correlation
dfcorr=df1[["stock prices","google trends"]]

corrstat=dfcorr.corr()
print(corrstat)

#line graph
fig,(ax1,ax3)=plt.subplots(1,2,figsize=(14,5))
color1="blue"
color2="red"

ax1.set_xlabel("Dates",fontsize=12)
ax1.set_ylabel("Stock Prices($)", color=color1,fontsize=12)
ax1.plot(df1["stock prices"],color=color1,label="GME")
ax1.tick_params(axis="y",labelcolor=color1)

ax2=ax1.twinx()
ax2.set_ylabel("Google trends", color=color2,fontsize=12)
ax2.plot(df1["google trends"],color=color2,label="Google Trends")
ax2.tick_params(axis="y",labelcolor=color2)

h1,l1=ax1.get_legend_handles_labels()
h2,l2=ax2.get_legend_handles_labels()
ax1.legend(h1+h2,l1+l2,loc='lower left',frameon=True,bbox_to_anchor=(1.05,0))
plt.title("GME's Stock Prices and Google Trends",fontsize=15)


#scatter plot
sns.scatterplot(x=df1.iloc[: , 4],y=df1.iloc[:,7],ax=ax3)
ax3.set_xlabel("Stock Prices",fontsize=12)
ax3.set_ylabel("Google trends",fontsize=12)
ax3.set_title("Scatterplot",fontsize=15)
ax1.grid()
ax3.grid()
fig.tight_layout()
plt.show()


#percentage Change
df1["lagStockprices"]=df1["stock prices"].shift(1)
df1["changeStockprices"]=df1["stock prices"]-df1["lagStockprices"]
df1["StockPerChange"]=df1["changeStockprices"]/df1["lagStockprices"]

df1["lagTrends"]=df1["google trends"].shift(1)
df1["changeTrends"]=df1["google trends"]-df1["lagTrends"]
df1["TrendsPerChange"]=df1["changeTrends"]/df1["lagTrends"]

df1=df1.dropna()
dfcorr=df1[["StockPerChange","TrendsPerChange"]]

corrstatchange=dfcorr.corr()
print('Percentage Change')
print(corrstatchange)

#save as csv
corrstat.to_csv('GME correlations.csv')
corrstatchange.to_csv('GME correlations.csv',mode='a')

#save as txt
with open('GME correlations.txt','a')as f_handle:
    np.savetxt(f_handle,corrstat)
    np.savetxt(f_handle,corrstatchange)


























