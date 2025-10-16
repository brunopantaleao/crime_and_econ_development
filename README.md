# README: Replication Package for
"Improving police management boosts economic development: evidence from Brazil"

Author: Bruno Pantaleão

Date: October 2025

Software: Stata 14 or later

---

## 1. Overview

This replication package reproduces all analyses and figures reported in Police Reform, Violence, and Local Economic Development in Brazil. The study evaluates the causal effects of staggered police reforms implemented across Brazilian states on local economic outcomes such as employment, firm density, and income.

The empirical strategy follows modern staggered difference-in-differences estimators (Callaway & Sant’Anna, 2021) and includes a series of robustness checks, heterogeneity analyses, and complementary designs (reduced forms, instrumental variables, and sensitivity tests).

---

## 2. Replication Files

```
main_data

data_quartil

data_metropolitan

data_setores

painel_crime_propriedade_mg_2015_2025

sensibilidade_homic

reproduction_sv2010_with_econ_data

---

## 3. Replication Instructions

### Step 1: Set Working Directory

Before running, update all directory paths in the `.do` files to your local replication folder:

```stata
cd "C:\path\to\ReplicationPackage"
```

### Step 2: Run Scripts

Run the scripts in the following order:

01_main_analysis.do 

---

## 4. Required Stata Packages

Please ensure the following user-written packages are installed:

```stata

net install csdid2, from("https://friosavila.github.io/stpackages")

ssc install eventdd, replace

ssc install outreg2, replace

ssc install coefplot, replace

ssc install nsplit, replace

ssc install xtivreg2, replace
```

---

## 5. Output Files

Tables: Saved as `.xls` files in `/Output/Tables/` (e.g., `csdidnt.xls`, `rf.xls`, `iv_homic.xls`).
 
Figures: All event-study and coefficient plots are exported as `.pdf` or `.png` in `/Output/Figures/`.
 
Logs: Execution logs for reproducibility are stored in `/Output/Logs/`.

---

## 6. Notes on Data

All data are publicly available from official Brazilian sources, including:

 RAIS/CAGED (Ministry of Labor, obtained through Basedosdados datalake)

 DATASUS (Health Ministry, obtained from R package microdatasus)

 IBGE (Brazilian Institute of Geography and Statistics, obtained from R package brpop)

 State Public Security Data from Minas Gerais

 Replication file for Viveiros and Soares (2010) [obtained from correspondence with the authors]


For replication, ensure that dataset names and variable structures match those referenced in the `.do` files.

---

## 7. Contact

For questions or replication issues:

Bruno Pantaleão

Email: bruno.oliveira@sciencespo.fr

Institution: Fundação Getulio Vargas (FGV)
