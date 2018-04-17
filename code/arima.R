#Arima R script

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


#create time series plot
pdf('../images/orignal_ts.pdf')
plot(female_birthrates, main = "Original Time Series")
dev.off()

#show outlier
outliers <- tso(female_birthrates, types = c("TC", "AO", "LS", "IO", "SLS"))

pdf('../images/outliers.pdf')
plot(outliers)
dev.off()

#remove outlier
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

#plot original time series and time series without outlier
pdf('../images/outlier_affect.pdf')
par(mfrow = c(3, 1))
plot(female_birthrates, main = "Original Time Series")
plot(birthrates_wo_ao, main = "Time Series without Outlier")
plot(ao_effect_ts, main = "Outlier Plot")
dev.off()

#generate birthrates time series without outlier
rownames(birthrates_wo_ao) <- clean_birthrates$date

#replace female_birthrates data frame
female_birthrates <- birthrates_wo_ao

#plot time series with no outlier
pdf('../images/ts_no_outlier.pdf')
plot.ts(female_birthrates, main = "Time Series Plot of Female Birthrate Data (Outlier Removed)")
dev.off()

#plot acf and pacf of ts
pdf('../images/original_ts_acf_pacf.pdf')
par(mfrow = c(2, 1))
acf(female_birthrates, main = "ACF of Birthrates Time Series")
pacf(female_birthrates, main = "PACF of Female Birthrates")
dev.off()

#plot ts with regression line
pdf('../images/trend_in_ts.pdf')
plot.ts(female_birthrates, main = "Time Series with OLS regression line")
abline(reg = lm(female_birthrates ~ time(female_birthrates)), col = 'red')
dev.off()


#get model
reg = lm(female_birthrates ~ time(female_birthrates))

#plot detrended time series vie OLS regression
pdf('../images/detrended_ts.pdf')
plot(resid(reg), type = 'l', main = "Detrended via Simple OLS", ylab = "Birthrates Detrended", xlab = "Time")
abline(lm(resid(reg) ~ time(resid(reg))), col = 'red')
dev.off()

pdf('../images/detrended_ts_acf_pacf.pdf')
par(mfrow = c(2, 1))
acf(resid(reg), main = "ACF of Birthrates Detrended via OLS")
pacf(resid(reg), main = "PACF of Birthrates Detrended via OLS")
dev.off()

#take the first difference of the time series
diff_vals <- diff(female_birthrates)

#plot diff of time series with linear region line
pdf('../images/first_diff_ts.pdf')
ts.plot(diff(female_birthrates), main = "First Difference of Birthrates Time Series")
abline(reg = lm(diff(female_birthrates) ~ time(diff(female_birthrates))), col = 'red')
dev.off()

pdf('../images/firstdiff_ts_acf_pacf.pdf')
par(mfrow = c(2, 1))
acf(diff(female_birthrates), main = "ACF of First Difference of Birthrates")
pacf(diff(female_birthrates), main = "PACF of First Difference of Birthrates")
dev.off()

#get second diff
second_diff_vals <- diff(diff(female_birthrates))

#plot second diff of time series with linear region line
pdf('../images/second_diff_ts.pdf')
ts.plot(diff(diff(female_birthrates)), main = "Second Difference of Birthrates Time Series")
abline(reg = lm(diff(diff(female_birthrates)) ~ time(diff(diff(female_birthrates)))), col = 'red')
dev.off()


pdf('../images/seconddiff_ts_acf_pacf.pdf')
par(mfrow = c(2, 1))
acf(diff(diff(female_birthrates)), main = "ACF of Second Difference of Birthrates")
pacf(diff(diff(female_birthrates)), main = "PACF of Second Difference of Birthrates")
dev.off()


#fit model

#first arima
pdf('../images/first_model.pdf')
first_model <- sarima(female_birthrates, 7, 1, 1)
dev.off()

first_aic <- paste('AIC:', first_model$AIC, sep = ' ')
first_aicc <- paste('AICc:', first_model$AICc, sep = ' ')
first_bic <- paste('BIC:', first_model$BIC, sep = ' ')

#model diagnostics
sink('../results/first_model.txt')
first_aic
first_aicc
first_bic
sink()

#second arima
pdf('../images/second_model.pdf')
second_model <- sarima(female_birthrates, 20, 1, 21)
dev.off()

second_aic <- paste('AIC:', second_model$AIC, sep = ' ')
second_aicc <- paste('AICc:', second_model$AICc, sep = ' ')
second_bic <- paste('BIC:', second_model$BIC, sep = ' ')

#model diagnostics
sink('../results/second_model.txt')
second_aic
second_aicc
second_bic
sink()

#third arima
pdf('../images/third_model.pdf')
third_model <- sarima(female_birthrates, 1, 1, 1)
dev.off()

third_aic <- paste('AIC:', third_model$AIC, sep = ' ')
third_aicc <- paste('AICc:', third_model$AICc, sep = ' ')
third_bic <- paste('BIC:', third_model$BIC, sep = ' ')

#model diagnostics
sink('../results/third_model.txt')
third_aic
third_aicc
third_bic
sink()

#forecast
pdf('../images/arima_forecast.pdf')
first_forcast <- sarima.for(female_birthrates, n.ahead = 10, p= 20, d = 1, q = 21)
dev.off()

pdf('../images/arima_forecast_2.pdf')
second_best_forcast <- sarima.for(female_birthrates, n.ahead = 10, p= 7, d = 1, q = 1)
dev.off()

train <- female_birthrates[1:355]
test <- female_birthrates[356:365]

pdf('../images/train_arima_forecast.pdf')
train_forcast <- sarima.for(train, n.ahead = 10, p= 20, d = 1, q = 21)
dev.off()

arima_preds <- train_forcast$pred

arima_test_mse1 <- sum((1/10)*(test - arima_preds)^2)

pdf('../images/train_second_arima_forecast.pdf')
second_train_forecast <- sarima.for(train, n.ahead = 10, p= 7, d = 1, q = 1)
dev.off()

second_arima_preds <- second_train_forecast$pred

arima_test_mse2 <- sum((1/10)*(test - second_arima_preds)^2)

ar_test_1 <- paste("Best ARIMA Model Test MSE:", arima_test_mse1, sep = ' ')
ar_test_2 <- paste("Second Best ARIMA Model Test MSE:", arima_test_mse2, sep = ' ')

sink('../results/arima_test_results.txt')
ar_test_1
ar_test_2
sink()















