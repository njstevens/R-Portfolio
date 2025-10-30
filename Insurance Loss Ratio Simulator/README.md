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
- `trustdata`: summarized member-level premium and incurred losses over 5, 10, and inception periods.  
- `ecarm`: detailed claim-level dataset with accident dates, policy effective dates, and incurred loss amounts.  
- Includes a custom Pareto random-number generator `rpareto1()` for heavy-tailed severity modeling.

Output:
- `trustdata` and `ecarm` are automatically created in the environment for use by the app.

---

### **2️⃣ Loss_Simulation_Functions.R**

Implements the statistical and visualization logic used in the app.

**Key functions:**
- **`trust.LossesAssesment()`** — computes claim frequency and severity by deductible and produces interactive Dygraphs.  
- **`trust.simLosses()`** — simulates annual loss experience using a Poisson (frequency) and Exponential (severity) model with configurable deductibles and loss adjustments.  
- **`trust.200Scenarios()`** — runs 200 Monte Carlo simulations of loss ratios under multiple pricing strategies to visualize expected performance ranges.  
- **`trust.GenSimPlot()`** — generates interactive time-series Dygraphs of simulated loss-ratio trajectories.  
- **`trust.SimLossIQ()`** — quick diagnostic simulation of expected incurred losses under given deductibles.

---

### **3️⃣ app.R**

Defines the **user interface and server logic** for the Shiny dashboard.

**UI features**
- Sidebar inputs for:
  - Member number  
  - Deductible amount  
  - Pricing strategy selection  
  - Loss-severity adjustment slider  
- Tabs for:
  - *Loss Severity Assessment*  
  - *Loss Frequency Assessment*  
  - *Simulated Loss Ratios* visualization  

**Server logic**
- Dynamically calls the functions above to compute and render:
  - Frequency and severity Dygraphs (`trust.LossesAssesment`)  
  - Multi-scenario loss-ratio simulations (`trust.200Scenarios`, `trust.GenSimPlot`)  

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
   - Generate synthetic data (`trustdata`, `ecarm`)  
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

- Default data are simulated; replace `trustdata` and `ecarm` with real datasets as needed.  
- All paths are relative — anyone cloning this repo can run it without modification.  
- To deploy on [shinyapps.io](https://www.shinyapps.io) or [Posit Connect](https://posit.co/products/connect/), simply upload all three `.R` files together.

---

## 👨‍💻 Author

**Nick Stevens**  
M.S. Statistics — University of Utah  
Focus Areas: Applied Machine Learning, Statistical Modeling, and Business Intelligence  
