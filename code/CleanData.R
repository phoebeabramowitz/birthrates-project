#Description: This R file cleans our data

#load packages
library(dplyr)
library(astsa)
library(tseries)
library(TSA)
library(tsoutliers)

#read in data
raw_birthrates = read.csv("../data/daily-total-female-births-in-cal.csv")

#remove final row
clean_birthrates <- filter(raw_birthrates, Date!="Daily total female births in California")

#define column names
colnames(clean_birthrates) <-  c('date',"daily_female_births")

#convert dates to Data data type
clean_birthrates$date <- as.Date(clean_birthrates$date)

#make dates row names
birthrates <- clean_birthrates$daily_female_births
female_birthrates <- data.frame(birthrates)
rownames(female_birthrates) <- clean_birthrates$date

#convert to time series
female_birthrates <- ts(female_birthrates)

#check for outliers
outliers <- tso(female_birthrates, types = c("TC", "AO", "LS", "IO", "SLS"))

#get index and time of outlier
outlier_indx <- outliers$outliers$ind

#length of ts
n <- length(female_birthrates)

#find outlier effect
ao <- outliers("AO", outlier_indx)
ao_effect <- outliers.effects(ao, n)
coefhat <- as.numeric(outliers$outliers['coefhat'])
ao_effect <- coefhat*ao_effect

#generate outlier affect time series
ao_effect_ts <- ts(ao_effect, frequency = frequency(female_birthrates), start= start(female_birthrates))

#generate time series without outlier
birthrates_wo_ao <- female_birthrates - ao_effect_ts

#generate birthrates time series without outlier
rownames(birthrates_wo_ao) <- clean_birthrates$date

#replace female_birthrates data frame
female_birthrates <- birthrates_wo_ao

#write in data
write.csv(female_birthrates, file = "../data/clean_data.csv", row.names = TRUE)

