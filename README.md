# The Phillips Curve in the US, 1948–2003: Inflation, Unemployment and the Volcker Break

**Group project** – Econometrics, University of Perugia (Feb–May 2025)

## Question

Is there a trade-off between inflation and unemployment in the United States, and did it change after the Volcker disinflation of 1980?

## Data

Annual US inflation and unemployment rates, 1948–2003 (56 observations; `phillips` dataset from Wooldridge, *Introductory Econometrics*).

## Method

- Exploratory analysis: time series with major macroeconomic events (Korean War, oil shocks, 1970s stagflation, early-1980s disinflation), descriptive statistics, lags and first differences
- **Static Phillips curve:** `inf ~ unem`
- **Expectations-augmented Phillips curve:** `inf ~ unem + inf(t-1)`
- **Sub-sample analysis:** pre-Volcker (1948–1979) vs post-Volcker (1980–2003), with a **Chow test** for a structural break
- **Diagnostics:** VIF (multicollinearity), Breusch-Pagan (heteroskedasticity), RESET (specification)
- **Forecasting:** regression with AR(1) errors and three unemployment scenarios (5%, 6%, 7%) for 2004–2006

## Results

| Model | Unemployment coefficient | Lagged inflation | Adj. R² |
|---|---|---|---|
| Static (1948–2003) | +0.50 (not significant) | – | 0.04 |
| Augmented (1948–2003) | −0.22 (not significant) | **0.73\*\*\*** | 0.46 |
| Pre-Volcker (1948–1979) | −0.05 (not significant) | **0.62\*\*** | 0.28 |
| Post-Volcker (1980–2003) | **−0.52\*** | **0.92\*\*\*** | 0.78 |

- The static model finds no trade-off; once past inflation is included, **inflation inertia** dominates, consistent with adaptive expectations.
- After 1980 the classic negative trade-off **re-emerges** and the model explains 78% of inflation's variation; however, the Chow test does not detect a statistically significant break for the full model (F = 0.53, p = 0.66).
- No multicollinearity (VIF = 1.41) and no specification errors (RESET p = 0.94), but **heteroskedasticity** is present (Breusch-Pagan p = 0.002), so robust standard errors are advisable.
- Forecast inflation for 2004–2006: about **3.3–3.7%** with 5% unemployment, **2.6–3.0%** with 6% and **1.9–2.3%** with 7%.

## Contents

- `phillips_curve_analysis.R` – full R script (expects the dataset saved as `phillips.xlsx`)

## Tools

R · ggplot2 · dplyr · psych · lmtest · car · sandwich · strucchange · forecast
