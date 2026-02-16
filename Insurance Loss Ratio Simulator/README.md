# 🧮 General Liability Loss Simulator

An interactive **R Shiny application** that models and visualizes **insurance loss ratios** under various deductible levels and premium-pricing strategies.  
The app provides actuaries and analysts with a dynamic tool for exploring how frequency, severity, and strategy adjustments influence profitability.

---

## 📁 Project Structure

```
Insurance Loss Ratio Simulator/
│
├── Loss Simulator App.R                          # Main Shiny application file
├── Loss Simulation Functions.R    # Core simulation and plotting functions
└── generated_data_for_loss_simulation.R  # Example synthetic data generator
```

---

## ⚙️ Dependencies

Install the required R packages before running the app:

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyWidgets", "shinythemes", 
  "shinycssloaders", "dygraphs", "tidyverse", "lubridate", 
  "janitor", "EnvStats", "scico", "DT", "flexdashboard"
))
```

---

## 🧩 Script Descriptions

### **1️⃣ generated_data_for_loss_simulation.R**

Generates **synthetic loss data** for demonstration purposes:
- `premium_data`: summarized member-level premium and incurred losses over 5, 10, and inception periods.  
- `loss_data`: detailed claim-level dataset with accident dates, policy effective dates, and incurred loss amounts.  
- Includes a custom Pareto random-number generator `rpareto1()` for heavy-tailed severity modeling.

Output:
- `premium_data` and `loss_data` are automatically created in the environment for use by the app.

---

### **2️⃣ Loss_Simulation_Functions.R**

Implements the statistical and visualization logic used in the app.

**Key functions:**
- **`LossesAssesment()`** — computes claim frequency and severity by deductible and produces interactive Dygraphs.  
- **`simLosses()`** — Core function for monte carlo simulation.  Losses are simulated using a Negative Binomial (frequency) and Exponential (severity) model with configurable deductibles and loss adjustments.  See below for detailed information.
- **`run_simulations()`** — runs 200 horizon scenarios calling simLosses and computing the average year over year loss ratio, selects 20 random simulations to display in a plot with the average.
- **`GenSimPlot()`** — generates interactive time-series Plotly of simulated loss-ratio trajectories.  

# simLosses Function Details

## Purpose
Simulates annual insurance losses and earned premiums for a single member using **experience-based pricing strategies**.  
Premiums and deductibles dynamically adjust based on **loss frequency** and **loss ratio trends**, reflecting realistic underwriting and pricing behavior.

---

## Simulation Logic
- **Claim Frequency:** Simulated using a **negative binomial distribution**.  
- **Claim Severity:** Simulated using an **exponential distribution** multiplied by a `LossAdjuster`.  
- **Deductible:** Can adjust annually based on improving or worsening loss experience.  
- **Total Incurred Losses:** Calculated cumulatively each year for the simulation period.

---

## Pricing Strategy Logic
- **Dynamic Premiums:** Adjusted based on:
  - **Frequency Trends:** Declining frequency can hold premiums flat or reduce them.
  - **Loss Ratios:** High loss ratios trigger premium increases; low ratios may trigger reductions.
- **Deductible Adjustments:** Deductibles decrease when loss experience improves, rewarding good risk behavior.
- **Experience-Based Window:** Rolling window of `n` years (default = 3) is used to evaluate trends.

---

## Flexible Term Selection
- Supports simulation over:
  - **5-year period**
  - **10-year period**
  - **Inception-to-date**  
Based on historical premium and loss data.

---

## Outputs
- `"LR"` → Yearly **Loss Ratios**  
- `"Premiums"` → Yearly **Current Premiums**  
- `"fullTable"` → Yearly **Cumulative and Current Losses, Premiums as well as loss ratios and current deductibles**  
- **Default** → includes everything generated from the function

---

## Parameters
| Parameter | Description |
|-----------|-------------|
| `PremData` | Member premium data. |
| `LossData` | Member loss history data. |
| `LRTerm` | Term to simulate (`"Five"`, `"Ten"`, `"Inception"`). |
| `MemberNumber` | Member identifier to simulate. |
| `base_deductible` | Starting deductible for simulations. |
| `LossAdjuster` | Multiplier to adjust simulated losses. |
| `TblOutput` | Determines output table format. |
| `n_years` | Number of years to simulate (default = 50). |
| `window` | Rolling window for experience calculation (default = 3 years). |

---




### **3️⃣ app.R**

Defines the **user interface and server logic** for the Shiny dashboard.

**UI features**
- Sidebar inputs for:
  - Member number  
  - Deductible amount  
  - Pricing strategy selection  
  - Loss-severity adjustment
- Tabs for:
  - *Loss Severity Assessment*  
  - *Loss Frequency Assessment*  
  - *Simulated Loss Ratios* visualization  

**Server logic**
- Dynamically calls the functions above to compute and render:
  - Frequency and severity Dygraphs (`LossesAssesment`)  
  - Multi-scenario loss-ratio simulations (`simLosses`, `GenSimPlot`)  

**Path handling**
- Automatically sets the working directory to the script location so the app runs correctly for anyone cloning the repo.

---

## ▶️ How to Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/Insurance Loss Ratio Simulator.git
   cd ThesisApp
   ```

2. Open `app.R` in RStudio.

3. Run the app:
   ```r
   shiny::runApp()
   ```
   or simply click **“Run App”** in RStudio.

4. The app will automatically:
   - Generate synthetic data (`premium_data`, `loss_data`)  
   - Load all loss simulation functions  
   - Launch an interactive dashboard

---

## 📊 Simulation Overview

**Distributions used:**
- Claim counts → Negative Binomial / Poisson  
- Claim severities → Exponential with occasional Pareto tail events  
- Premium growth strategies:
  - *Organic* (3% / year)
  - *Organic Heavy* (5% / year)
  - *Moderate Aggressive* (15% initial + 5% / year)
  - *Aggressive* (30% initial + 5% / year)
  - *Extreme* (50% initial + 5% / year)

**Outputs:**
- Interactive Dygraphs showing:
  - Loss-severity trends under multiple deductibles  
  - Claim-frequency evolution over time  
  - Simulated loss-ratio trajectories with confidence bands

---

## 🧠 Notes

- Default data are simulated; replace `premium_data` and `loss_data` with real datasets as needed.  
- All paths are relative — anyone cloning this repo can run it without modification.  
- To deploy on [shinyapps.io](https://www.shinyapps.io) or [Posit Connect](https://posit.co/products/connect/), simply upload all three `.R` files together.

---

## 👨‍💻 Author

**Nick Stevens**  
M.S. Statistics — University of Utah  
Focus Areas: Applied Machine Learning, Statistical Modeling, and Business Intelligence  
