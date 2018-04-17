Report Writeup
================
Phoebe Abramowitz
4/13/2018

Introduction
============

*Elaborate on the background of the problem/dataset. Where does the dataset come from? How are the data collected?*

The dataset describes the number of female births by day in California in 1959, January first through December 31st. The units are a count and there are 365 observations. The data is provided by the Time Series Data Library, found at <https://datamarket.com/en/data/list/?q=provider:tsdl>. The data comes from analysis of birth certificates.

*Explain the motivation for studying the particular dataset of interest. Why is the dataset interesting?*

This dataset is both interesting for the sake of general curiosity and for the impact that date of birth can have on individuals' lives. For example, in his popular book *Outliers*, Malcolm Gladwell demonstrates that being born on a date such that you're the oldest of your cohort in school and childhood activities leads to increased rates of success in academia, sports, ect. Regardless of it's veracity, astrology is an immensely popular way for people to make sense of their lives. Timing of birth-down to the specific day- can affect people's perceptions of themselves and their circumstances. These perceptions can then impact people's decision making.
"The birthday problem" is often discussed in the study of probability. The problem, which asks how likeley it is that at least two people in a group share a birthday, is often prefaced with the assumption that "all birthdays are equally likeley". However, the reasoning for and extent of the disclaimer that this is not necessarily true is rarely expounded upon in these discussions.

EDA
===

Before we begin our analysis of the Female Birthrates time series, we need to do some exploratory data analysis. First, let’s plot the original time series.

![original\_time\_series](../images/orignal_ts.pdf)

Before we continued, we checked for outliers using the method suggested to us. Using the tso() function, we saw we had one additive outlier at time 266. Interesting, we found that this outlier could correlate with conception on New Years Eve, or just during the holidays in general, so the outlier does make sense. We decided to remove this outlier. Here is a plot showing the existence of the additive outlier:

![outlier](../images/outliers.pdf)

We decided to remove this outlier. Here is a plot showing the original time series vs the time series without the additive outlier:

![outlier\_affect](../images/outlier_affect.pdf)

Now that we have removed any outliers we can check for stationarity. The first thing we did was to see if there is an underlying trend in the data. In order to do that we fit a simple linear model, regressing birthrates on time. Below you can see a plot of the time series with the regression line. Clearly the time series has a trend, and the mean is based on time, meaning the time series is not stationary.

![trend](../images/trend_in_ts.pdf)

We have two options to try to make this time series stationary. The first is we can de-trend the time series by subtracting the linear trend. In order to do that, we just examine the residuals of regression birthrates on time. Below is the time series de-trended via OLS.

![detrend](../images/detrended_ts.pdf)

Clearly the mean is not dependent on time, but in order to check if this time series is stationary we need to check the ACF and PACF of the de-trended time series. Below is the ACF and PACF of the de-trended time series.

![detrend\_acf\_pacf](../images/detrended_ts_acf_pacf.pdf)

For both the PACF and ACF the values are not tailing off, and actually reach a spike at lag-21 before tailing off. This could mean the time series is not stationary, or it could mean the time series is seasonal.

In order to see if the time series is seasonal lets look at the original ACF and PACF of the time series.

![orginal\_acf\_pacf](../images/original_ts_acf_pacf.pdf)

There doesn’t seem to be a seasonal trend in the original time series or the de-trended time series. We will come back to this when we are fitting our ARIMA model, but we have strong evidence throughout our analysis that this data is not seasonal.

The next step would be to look at the differenced time series. Below is the differenced time series with a line noting the average of the time series. Clearly the mean of differenced time series does not depend on time.

![differnced\_ts](../images/first_diff_ts.pdf)

Now we can look at the ACF and PACF of the time series. These will also be used to try to fit our ARIMA model later. Below is the ACF and PACF of the differenced time series.

![differnced\_ts\_acf\_pacf](../images/firstdiff_ts_acf_pacf.pdf)

Once again we don’t have clear evidence this is stationary. Clearly the model is not just a AR or MA model, since both the PACF and ACF don’t cut off sharply. For the ACF the significance seems to cut off after lag-1, but there is a spike at lag-21. For the PACF the significance cuts off after lag-7, but there is a spike at lag-20. Neither the PACF nor ACF tails off.

Because we don’t have strong evidence we have a stationary time series yet we are going to look at the second difference of the time series. Because we want to avoid over-differencing for our ARIMA models, we will only use the second difference if it clearly makes the model look stationary. Below is the plot of the second differenced time series, followed by the ACF and PACF plots

![second\_diff\_ts](../images/second_diff_ts.pdf)

![seconddiff\_ts\_acf\_pacf](../images/seconddiff_ts_acf_pacf.pdf)

There isn’t any strong evidence that differencing again made an impact on making the time series more stationary, so to avoid over-differencing we will only look at the first difference for out models.

ARIMA
=====

Based on the first difference, we don’t have evidence that we have a purely MA or AR model. However, the last significant lag for the PACF is lag 20 and the last significant lag for the ACF is lag-21. Because of this one of the models we will try to fit will be an ARIMA(20, 1, 21) model. However, this model is very complicated, and we want to avoid over-fitting our data. Because of this, we will look at two simpler ARIMA models as well. Note that for the PACF of the first difference of the time series, the significance cuts off at lag-7, before reaching a spike at lag-20. In addition, for the ACF the significance cuts off at lag-1 before reaching a spike at lag-21. Because of this we will also fit an ARIMA(7, 1, 1) model. We also wanted to look at an overly-simple model, and fit an ARIMA(1, 1, 1) model.

Using sarima() here are the results of the ARIMA(20, 1, 21) model:

![second\_model](../images/second_model.pdf)

There are several insights the plots from sarima() provide for us here. For one, the Normal Q-Q plot of standardized residuals tells us that the residuals are normally distributed, so the assumption of a Gaussian distribution is valid. We also see from the ACF of the residuals that the ACF at any lag is within the innovations significance bar, which gives evidence that this is a good model. Before looking at the model statistics, lets use sarima() on the other two models.

Here are the results of running sarima() on the ARIMA(7, 1, 1) model:

![first\_model](../images/first_model.pdf)

Once again the assumption of normality is supported, but there is a spike at lag-21 for the ACF of the residuals, implying this may not be a great model.

Let’s look at the ARIMA(1, 1, 1) model, and then compare the model statistics for each:

![third\_model](../images/third_model.pdf)

The plots for this model look similar to ARIMA(7, 1, 1), however, the Ljung-Box statistics is showing higher p-values, implying this is a worse model.

Let’s look at the model statistics for each model.

Here is the AIC, AICc, and BIC of the first model:

AIC: 4.89305737044942 AICc: 4.93083315673372 BIC: 4.3418126823685

Here is the AIC, AICc, and BIC of the second model:

AIC: 4.87895885933218 AICc: 4.88614096598027 BIC: 3.97512071188627

Here is the AIC, AICc, and BIC of the third model:

AIC: 4.86904410372145 AICc: 4.87482796977929 BIC: 3.90109805457282

The ARIMA(20, 1, 21) model has the best model statistics. However, as I mentioned before, I don't want to only look at a very complicated model, so I will continue to analyze ARIMA(7, 1, 1), since it has the second best model statistics.

In order to find which of these two models is best, I am going to see how they perform in forecasting unseen data. I am going to train both models using a train data set with the last 10 observations from female birthrates missing, then see how well the models can forecast these 10 observations.

Below you can see the plot when I forecasted using the training set on the ARIMA(20, 1, 21) model:

![train\_arima\_forecast](../images/train_arima_forecast.pdf)

And now below you can see the plot when I forecasted using the training set on the ARIMA(7, 1, 1) model:

![train\_second\_arima\_forecast](../images/train_second_arima_forecast.pdf)

Both forecasts don't look like they are doing great, but let's compare the test MSE to see which one performed better.

The test MSE for the ARIMA(20, 1, 21) model was 46.5991992308594.

The test MSE for the ARIMA(7, 1, 1) model was 47.546990399347.

As you can see the test MSE of the ARIMA(20, 1, 21) model was slightly better. We can now move on to forecasting the best model, the ARIMA(20, 1, 21) model. Below is the 10 step ahead forecast for the ARIMA(20, 1, 21 model):

![arima\_forecast](../images/arima_forecast.pdf)

As you can see, the forecast does not look like it is doing a great job, and the confidence interval is much too large. We have pretty clear evidence that an ARIMA method will not be able to model the female birthrates dataset.

Conclusion
==========

Given that we only have data for one year, accounting for the spike in September, which could be seasonality if looked at over multiple years, is out of the scope of our analysis. It's impossible to tell from our dataset how much of the upward trend demonstrated by slope of our OLS regression line is due to a long-term increase in birthrates, and how much of it is due to a seasonal increase in birthrates as an individual year progresses from January. It's worthwhile to analyze similar birthdate data over several years. The spike in September suggests that people are concieving around the holidays. It's possible that the outlier at 266 days is caused by conception on or around New Years Eve. This discussion of birthrates on particular dates also suggest that it would be interesting to look at data regarding gestation time from conception to birth.
