# Econometrics – Group H Assignments
# ---- 1. Load the dataset and examine the time series of inf and unem from 
#1948 to 2003.* ---- 
#Visualize trends, identifying major macroeconomic events (e.g., stagflation 
#of the 1970s, disinflation post-1980). Compute and plot descriptive 
#statistics, lags, and first differences.*

#Download the dataset "phillips.xlsx"
library(readxl)             

dati <- read_excel("phillips.xlsx", col_types = c("numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

# Plot with ggplot2
library(ggplot2)
library(scales) 

#plot the graph
ggplot(dati, aes(x = year)) +
  geom_line(aes(y = inf, color = "Inflation")) +
  geom_line(aes(y = unem, color = "Unemployment")) +
  scale_color_manual(values = c("Inflation" = "red", "Unemployment" = "blue")) +
  scale_x_continuous(breaks = seq(1948, 2003, by = 10)) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(title = "Inflation and Unemployment (1948–2003)",
       x = " ", y = " ", color = "Variables") +
  geom_rect(xmin = 1980, xmax = 1983, ymin = -Inf, ymax = Inf,
            fill = "wheat1", alpha = 0.01) + 
  geom_rect(xmin = 1948, xmax = 1949, ymin = -Inf, ymax = Inf,
            fill = "wheat1", alpha = 0.01) + 
  geom_rect(xmin = 1950, xmax = 1953, ymin = -Inf, ymax = Inf,
            fill = "wheat1", alpha = 0.01) + 
  geom_rect(xmin = 1972, xmax = 1974, ymin = -Inf, ymax = Inf,
            fill = "darkseagreen1", alpha = 0.01) + 
  geom_rect(xmin = 1978, xmax = 1980, ymin = -Inf, ymax = Inf,
            fill = "darkseagreen1", alpha = 0.01) + 
  geom_rect(xmin = 1982, xmax = 1984, ymin = -Inf, ymax = Inf,
            fill = "darkseagreen1", alpha = 0.01) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

#1950: inflation spike due to the Korean War
#1970: stagflation: with high levels of unemployment and inflation
#1973 and 1979: oil crisis
#1980: unemployment peak (this may be a consequence of the restrictive monetary 
#policies adopted to combat inflation)

#descriptive statistics for the variable "inf"
library(psych)

describe(dati$inf)

#descriptive statistics for the variable "unem"
describe(dati$unem)

#lags
library(dplyr)

# Calculate the lag 1 (previous period value) for inflation (inf) and unemployment (unem)
dati <- dati %>% mutate(inf_lag1 = lag(inf, n = 1),
                        unem_lag1 = lag(unem, n = 1))

# Visualize the original series vs. lag 1
# This helps you see the relationship between the current and past values
ggplot(dati, aes(x = inf_lag1, y = inf)) +
  geom_point() +
  labs(title = "Inflation vs. Inflation (Lag 1)",
       x = "Previous year inflation",
       y = "Current year inflation ") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

#first differences
dati <- dati %>%
  mutate(
    inf_diff = inf - lag(inf, n = 1),
    unem_diff = unem - lag(unem, n = 1)
  )
#inflation
ggplot(dati, aes(x = year)) + 
  geom_line(aes(y = inf_diff), color = "blue") +
  labs(title = "First differences for inflation",
       y = "Variation of inflation") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

#unemployment
ggplot(dati, aes(x = year)) + 
  geom_line(aes(y = unem_diff), color = "red") +
  labs(title = "First differences for unemployment",
       y = "Variation of unemployment") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# ---- 2. Estimate the classical Phillips Curve model: ---- 
#Explain the expected sign of 𝛽1 based on economic theory. 
#What does the slope tell us about the inflation-unemployment tradeoff?*

modello_phillips <- lm(inf ~ unem, data = dati)
summary(modello_phillips)

# ---- 3.  Augment your model to include dynamics: ---- 
# 𝑖𝑛𝑓 𝑡 = 𝛽0 + 𝛽1⋅ 𝑢𝑛𝑒𝑚𝑡 + β2⋅ 𝑖𝑛𝑓 𝑡−1 + 𝑢𝑡
#Discuss the role of inflation expectations and inertia in the modern Phillips 
#Curve.

#Computation of the model
model <- lm(inf ~ unem + inf_lag1, data = dati)
summary(model)

# ---- 4. Split the sample into two periods: 1948–1979 (pre-Volcker) 
#and 1980–2003 (post-Volcker disinflation): ---- 
#Estimate the model separately for each period.
#Perform a Chow test to determine whether the relationship between inflation 
#and unemployment changed structurally after 1980.
#Discuss economic reasons for the shift (e.g., credibility of monetary policy, 
#globalization, labor market flexibility).

# Pre-Volcker (1948-1979)
df_pre_vol <- dati[dati$year >= 1948 & dati$year <= 1979, ]

# Post-Volcker  (1980-2003)
df_post_vol <- dati[dati$year >= 1980 & dati$year <= 2003, ]

#Estimation of the model for each period
# Pre-Volcker period
model_pre_vol <- lm(inf ~ unem + inf_lag1, data = df_pre_vol)
summary(model_pre_vol)

# Post-Volcker period
model_post_vol <- lm(inf ~ unem + inf_lag1, data = df_post_vol)
summary(model_post_vol)


##Perform a Chow test 
library(strucchange)

#Preparation to ChowTest
#We need a breakpoint, in our case is 1980
bp_idx <- which(dati$year == 1980)

#Chow Test (formula interface, so that strucchange runs a proper Chow F test;
#the first observation is dropped because inf_lag1 is NA in 1948)
dati_chow <- na.omit(dati[, c("year", "inf", "unem", "inf_lag1")])
bp_idx <- which(dati_chow$year == 1979) # last observation of the first regime
chow_test <- sctest(inf ~ unem + inf_lag1, data = dati_chow, type = "Chow", point = bp_idx)
chow_test 

# ---- 5. Test for multicollinearity (VIF), heteroskedasticity (Breusch-Pagan), 
#and specification errors (RESET test). Report whether your model assumptions 
#hold. ---- 

library(car)
library(lmtest)
library(sandwich)

#test for multicollinearity (VIF)
vif(model)

#compute the heteroskedasticity test (Breusch-Pagan)
bptest(model)

#test for specification errors (test RESET)
resettest(model)

# ---- 6. Using the best-fitting model from your earlier analysis, forecast 
#inflation for the next 3 years based on hypothetical unemployment scenarios 
#(e.g., 5%, 6%, 7%). Discuss confidence in your forecast and limitations. ----
library(forecast)

#Let's transform the inflation and unemployment columns into time series.
inf_ts <- ts(dati$inf, start = c(1948, 1), frequency = 1)
unem_ts <- ts(dati$unem, start = c(1948, 1), frequency = 1)

#The best-fitting model is the Phillips Curve augmented of point 3
#This corresponds to an AR(1) model with 'unem' as an external regressor. 
best_model_arima <- forecast::Arima(inf_ts, #Dependent variable
                                    order = c(1,0,0), # This row defines p=1, d=0, q=0
                                    xreg = unem_ts, #Exogenous variable
                                    include.mean = TRUE) 
summary(best_model_arima)

#Let's forecast for 3 years
forecast_horizon <- 3 

#Scenario 1: Unemployment constant at 5%
future_unem_5pct <- ts(rep(5, forecast_horizon), # unemployment is measured in percentage points (5 = 5%)
                       start = c(2004, 1), 
                       frequency = 1)      # annual data
# Scenario 2: Unemployment constant at 6%
future_unem_6pct <- ts(rep(6, forecast_horizon), start = c(2004, 1), frequency = 1)

# Scenario 3: Unemployment constant at 7%
future_unem_7pct <- ts(rep(7, forecast_horizon), start = c(2004, 1), frequency = 1)

forecast_5pct <- forecast(best_model_arima, h = forecast_horizon, xreg = future_unem_5pct)
forecast_6pct <- forecast(best_model_arima, h = forecast_horizon, xreg = future_unem_6pct)
forecast_7pct <- forecast(best_model_arima, h = forecast_horizon, xreg = future_unem_7pct)

inflation_forecasts_5pct <- as.numeric(forecast_5pct$mean) 
inflation_forecasts_6pct <- as.numeric(forecast_6pct$mean) 
inflation_forecasts_7pct <- as.numeric(forecast_7pct$mean) 

#The mean of a 'forecast' object contains the point estimate
forecast_table <- data.frame(
  Year = 2004:(2003 + forecast_horizon), 
  Inf_5pct_Unemp = inflation_forecasts_5pct,
  Inf_6pct_Unemp = inflation_forecasts_6pct,
  Inf_7pct_Unemp = inflation_forecasts_7pct
)
forecast_table



