#Description: This R file cleans our data

#load dplyr
library(dplyr)

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

#write in data
write.csv(female_birthrates, file = "../data/clean_data.csv", row.names = TRUE)
