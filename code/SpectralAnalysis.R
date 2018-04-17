#load packages
library(dplyr)
library(astsa)
library(tseries)
library(TSA)

#load data and detrend using differencing
source('./CleanData.R')
fem_birth <- diff(female_birthrates)

#make periodogram of the data
pdf('../images/periodogram.pdf')
spec.pgram(fem_birth)
dev.off()

#For smoothed periodogram, try different values for the kernel & taper
pdf('../images/smoothed-pgram-1.pdf')
spec.pgram(fem_birth,kernel('daniell',3), taper = 0.1)
dev.off()
pdf('../images/smoothed-pgram-2.pdf')
spec.pgram(fem_birth,kernel('modified.daniell',3), taper = 0.2)
dev.off()
pdf('../images/smoothed-pgram-3.pdf')
spec.pgram(fem_birth,kernel('modified.daniell',5), taper = 0)
dev.off()
pdf('../images/smoothed-periodogram.pdf')
spec.pgram(fem_birth,kernel('modified.daniell',c(1,6,1)), taper = 0.1,log="no")
dev.off()

#exhibit all local maxima
pdf('../images/pgram-local-maxima.pdf')
pgram <- spec.pgram(fem_birth,kernel('modified.daniell',c(1,6,1)), taper = 0.1,log="no")
key_freq_ind <- c(1, which(diff(sign(diff(pgram$spec)))==-2) + 1)
key_freq <- pgram$freq[key_freq_ind]
abline(v=key_freq, lty=3)
dev.off()

#choose the top three lags
top_freq <- key_freq[order(pgram$spec[key_freq_ind], decreasing = T)][1:3]

#compare to the parametric spectral estimator
pdf('../images/parametric-spectral-estimator.pdf')
pgram <- spec.pgram(fem_birth,kernel('modified.daniell',c(1,6,1)), taper = 0.1,log="no")
pgram_ar <- spec.ar(fem_birth, plot=F)
lines(pgram_ar$freq, pgram_ar$spec, lty=2, col="red")
dev.off()

#generate features
t <- 1:length(female_birthrates)
periodic_terms <- do.call(cbind, lapply(top_freq, function(freq) {
  cbind(cos(2 * pi * freq * t), sin(2 * pi * freq * t))
}))
df <- data.frame(female_birthrates, t, periodic_terms)
fit_final <- lm(female_birthrates ~ ., df)
#plot
pdf('../images/parametric-spectral-estimator.pdf')
plot(t, female_birthrates, type="l")
lines(t, fit_final$fitted.values, lty=2, col="red")
dev.off()

# forecast the next 30 obervations with a 95% confidence level.
t_new <- (tail(t, 1) + 1):(tail(t, 1) + 30)
periodic_terms_new <- do.call(cbind, lapply(top_freq, function(freq) {
  cbind(cos(2 * pi * freq * t_new), sin(2 * pi * freq * t_new))
}))
df_new <- data.frame(t_new, periodic_terms_new)
colnames(df_new) <- colnames(df)[-1]
predictions <- predict.lm(fit_final, newdata=df_new,interval="prediction", level=.95)
#plot predictions and interval
pdf('../images/spectral-predictions.pdf')
plot(t, female_birthrates, type="l", xlim=c(0, tail(t_new, 1)))
lines(t, fit_final$fitted.values, lty=2, col="red")
lines(t_new, predictions[, "fit"], col="blue")
matlines(t_new, predictions[, 2:3], col = "purple", lty=3)
dev.off()