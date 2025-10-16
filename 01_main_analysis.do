* -------------------------------------------------------------------------
* 01_main_analysis.do
* Replication: Police Reform, Violence, and Local Economic Development in Brazil
* Author: Bruno Pantaleão
* Date: October 2025
*
* Contents:
*   1. Data construction (full merges, cleaning)
*   2. Main CSDID (whole sample, Table 3)
*   3. Heterogeneity analyses (metro, violence quartiles, sector)
*   4. Dynamic lag regressions for homicide and property crimes
*
* Requires: Stata 14+, csdid2, outreg2, coefplot, nsplit, xtivreg2
* -------------------------------------------------------------------------

set more off

* --- Project directories ---
cd "C:/Users/bruno/Dropbox/Pesquisa/Publishing/World Deve/RR/Reproduction"

* ---------------------------
* 1. Required packages
* ---------------------------
net install csdid2, from("https://friosavila.github.io/stpackages")

foreach p in csdid eventdd outreg2 coefplot nsplit xtivreg2 {
    cap which `p'
    if _rc ssc install `p', replace
}


clear
use "C:\Users\bruno\Dropbox\Pesquisa\Publishing\World Deve\RR\Reproduction\main_data.dta"
drop if grupo==.

* ---------------------------
* 3. Main CSDID (Table 3)
* ---------------------------
foreach a in tx_firmas tx_total {
    csdid2 `a' lmassas [aweight=meanmpop], i(codmun) t(ano_morte) gvar(grupo) cluster(uf3) notyet
    estat simple
    outreg2 using "csdid_main.xls"
    estat event, revent(-6/8)
	outreg2 using "csdid_main.xls"
    estat event, revent(-6/8)
	matrix T = r(table)	
	matrix R=r(table)
	matrix CSp=J(16, 3, .)
	matrix rownames CSp = "-6" "-5" "-4" "-3" "-2" "0" "1" "2" "3" "4" "5" "6" "7" "8"
	local j=0
	forvalues i=1/16 {
		matrix CSp[`i',1]=R[1,`=`j'+3']
		matrix CSp[`i',2]=R[5,`=`j'+3']
		matrix CSp[`i',3]=R[6,`=`j'+3']
		local j=`j'+1
	}	
coefplot (matrix(CSp[,1]), ci((2 3)) pstyle(p4) msymbol(O) ciopts(recast(rcap) lpattern(solid) lcolor(black))), ///
	vertical graphregion(color(white)) bgcolor(white) ///
	xlabel(, noticks) ylabel(, noticks nogrid) xtitle("Years") ///
	ytitle("Average causal effect") yline(0, lcolor("182 39 37") lpattern(solid)) ///
	xline(5.5, lwidth(thin) lcolor(black)  lpattern(dash)) 
	graph export "csdid_`a'.pdf", replace
}



* ---------------------------
* 4. Heterogeneity analyses
* ---------------------------
clear
use "data_metropolitan"


* 4.1 Metropolitan vs non-metropolitan (Table 4)
foreach q in 0 1 {
foreach a in tx_firmas tx_total {
        csdid2 `a' lmassas if metropolitana==`q' [aweight=meanmpop], i(codmun) t(ano_morte) gvar(grupo) cluster(uf3) notyet
        estat simple
		outreg2 using "csdid_metro.xls" 
		estat event, revent(-6/8)
        outreg2 using "csdid_metro.xls" 
		estat event, revent(-6/8)
	matrix T = r(table)	
	matrix R=r(table)
	matrix CSp=J(16, 3, .)
	matrix rownames CSp = "-6" "-5" "-4" "-3" "-2" "0" "1" "2" "3" "4" "5" "6" "7" "8"
	local j=0
	forvalues i=1/16 {
		matrix CSp[`i',1]=R[1,`=`j'+3']
		matrix CSp[`i',2]=R[5,`=`j'+3']
		matrix CSp[`i',3]=R[6,`=`j'+3']
		local j=`j'+1
}	
coefplot (matrix(CSp[,1]), ci((2 3)) pstyle(p4) msymbol(O) ciopts(recast(rcap) lpattern(solid) lcolor(black))), ///
	vertical graphregion(color(white)) bgcolor(white) ///
	xlabel(, noticks) ylabel(, noticks nogrid) xtitle("Years") ///
	ytitle("Average causal effect") yline(0, lcolor("182 39 37") lpattern(solid)) ///
	xline(5.5, lwidth(thin) lcolor(black)  lpattern(dash)) 
	graph export "csdid_`a'_`q'.pdf", replace
}
}
 

* 4.2 Baseline violence quartiles (Table 5)

clear
use "data_quartil"

forvalues q = 1/4 {
    foreach a in tx_firmas tx_total {
        csdid2 `a' lmassas if quartil2==`q' [aweight=meanmpop], i(codmun) t(ano_morte) gvar(grupo) cluster(uf3)
		estat simple
		outreg2 using "csdid_quartil.xls" 
        estat event, revent(-6/8)
        outreg2 using "csdid_quartil.xls" 
        estat event, revent(-6/8)
	matrix T = r(table)	
	matrix R=r(table)
	matrix CSp=J(16, 3, .)
	matrix rownames CSp = "-6" "-5" "-4" "-3" "-2" "0" "1" "2" "3" "4" "5" "6" "7" "8"
	local j=0
	forvalues i=1/16 {
		matrix CSp[`i',1]=R[1,`=`j'+3']
		matrix CSp[`i',2]=R[5,`=`j'+3']
		matrix CSp[`i',3]=R[6,`=`j'+3']
		local j=`j'+1
	}	
coefplot (matrix(CSp[,1]), ci((2 3)) pstyle(p4) msymbol(O) ciopts(recast(rcap) lpattern(solid) lcolor(black))), ///
	vertical graphregion(color(white)) bgcolor(white) ///
	xlabel(, noticks) ylabel(, noticks nogrid) xtitle("Years") ///
	ytitle("Average causal effect") yline(0, lcolor("182 39 37") lpattern(solid)) ///
	xline(5.5, lwidth(thin) lcolor(black)  lpattern(dash)) 
	graph export "csdid_`a'_q`q'.pdf", replace
}
}




* 4.3 Sector heterogeneity (agriculture, industry, services) (Table 6)
use "data_setores.dta", clear

foreach a in tx_empregados_agro tx_empregados_ind tx_empregados_serv tx_empresas_agro tx_empresas_ind tx_empresas_serv {
    csdid2 `a' lmassa [aweight=meanmpop], i(codmun) t(ano_morte) gvar(grupo) cluster(uf3) notyet
    estat simple
    outreg2 using "csdid_sector.xls" 
		estat event, revent(-6/8)
	matrix T = r(table)	
	matrix R=r(table)
	matrix CSp=J(16, 3, .)
	matrix rownames CSp = "-6" "-5" "-4" "-3" "-2" "0" "1" "2" "3" "4" "5" "6" "7" "8"
	local j=0
	forvalues i=1/16 {
		matrix CSp[`i',1]=R[1,`=`j'+3']
		matrix CSp[`i',2]=R[5,`=`j'+3']
		matrix CSp[`i',3]=R[6,`=`j'+3']
		local j=`j'+1
	}	
coefplot (matrix(CSp[,1]), ci((2 3)) pstyle(p4) msymbol(O) ciopts(recast(rcap) lpattern(solid) lcolor(black))), ///
	vertical graphregion(color(white)) bgcolor(white) ///
	xlabel(, noticks) ylabel(, noticks nogrid) xtitle("Years") ///
	ytitle("Average causal effect") yline(0, lcolor("182 39 37") lpattern(solid)) ///
	xline(5.5, lwidth(thin) lcolor(black)  lpattern(dash)) 
	graph export "csdid_`a'.pdf", replace
}


* ---------------------------
* 5.1 Dynamic lag regressions (homicides)
* ---------------------------
use "sensibilidade_homic.dta"

xtreg tx_firmas homicide_rate lag1_homicide lag2_homicide lag3_homicide lag4_homicide [aweight=meanmpop], fe r
estimates store Firms_Homic
xtreg tx_total homicide_rate lag1_homicide lag2_homicide lag3_homicide lag4_homicide [aweight=meanmpop], fe r
estimates store Jobs_Homic
coefplot (Firms_Homic, title("Number of Firms")), drop(_cons) xline(0)
graph save "coefplot_firms_homic", replace
coefplot (Jobs_Homic, title("Number of Jobs"))  , drop(_cons) xline(0)
graph save "coefplot_jobs_homic", replace

graph combine "coefplot_firms_homic" "coefplot_jobs_homic"
graph export "Figure 3.pdf", replace

* ---------------------------
* 5.2 Dynamic lag regressions (property crime MG)
* ---------------------------

clear
use main_data
merge 1:1 codmun ano_morte using "painel_crime_propriedade_mg_2015_2025"
keep if _merge==3
drop _merge
xtset codmun ano_morte
tsfill, full
drop if ano_morte>2019
set scheme s1color

rename theft_trans theft_pedestrian
rename robbery_trans robbery_pedestrian

foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
gen rate_`x' = (`x'/pop)*100000
gen l_`x' = ln(1+(`x'/pop))
}

sort codmun ano
foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
gen lag1_`x' = rate_`x'[_n-1] if codmun==codmun
gen lag2_`x' = rate_`x'[_n-2] if codmun==codmun
gen lag3_`x' = rate_`x'[_n-3] if codmun==codmun
gen lag4_`x' = rate_`x'[_n-4] if codmun==codmun
}



foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
xtreg tx_firmas rate_`x', fe r
outreg2 using "mg1.xls"
xtreg tx_total rate_`x', fe r
outreg2 using "mg1.xls"
}


foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
xtreg tx_firmas rate_`x' [aweight=meanmpop], fe r
outreg2 using "mg2.xls"
xtreg tx_total rate_`x' [aweight=meanmpop], fe r
outreg2 using "mg2.xls"
}

foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
xtreg tx_firmas rate_`x' tx_homicidio_total [aweight=meanmpop], fe r
outreg2 using "mg3.xls"
xtreg tx_total rate_`x' tx_homicidio_total [aweight=meanmpop], fe r
outreg2 using "mg3.xls"
}

foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
label variable rate_`x' "`x'"
}


foreach x in theft_cargo theft_commerce theft_bank theft_home theft_pedestrian theft_transit theft_veic  {
xtreg tx_firmas rate_`x'  lag1_`x' lag2_`x' lag3_`x' lag4_`x'   [aweight=meanmpop], fe r
estimates store Number_of_Firms 
xtreg tx_total rate_`x' lag1_`x' lag2_`x' lag3_`x' lag4_`x'  [aweight=meanmpop], fe r
estimates store Number_of_Jobs
coefplot (Number_of_Firms, title("Number of firms")) , drop(_cons) xline(0)
graph save "coefplot_firms_`x'", replace
coefplot (Number_of_Jobs, title("Number of jobs")), drop(_cons) xline(0)
graph save "coefplot_jobs_`x'", replace
graph combine "coefplot_firms_`x'" "coefplot_jobs_`x'", rows(1) 
graph save "coefplot_`x'", replace
}


foreach x in robbery_cargo robbery_commerce robbery_bank robbery_home robbery_pedestrian robbery_transit robbery_veic {
xtreg tx_firmas rate_`x'  lag1_`x' lag2_`x' lag3_`x' lag4_`x'   [aweight=meanmpop], fe r
estimates store Number_of_Firms 
xtreg tx_total rate_`x' lag1_`x' lag2_`x' lag3_`x' lag4_`x'  [aweight=meanmpop], fe r
estimates store Number_of_Jobs
coefplot (Number_of_Firms, title("Number of firms")) , drop(_cons) xline(0)
graph save "coefplot_firms_`x'", replace
coefplot (Number_of_Jobs, title("Number of jobs")), drop(_cons) xline(0)
graph save "coefplot_jobs_`x'", replace
graph combine "coefplot_firms_`x'" "coefplot_jobs_`x'", rows(1) 
graph save "coefplot_`x'", replace
}



foreach x in cargo commerce bank home pedestrian transit veic {
graph combine  "coefplot_theft_`x'" "coefplot_robbery_`x'",  cols(1) rows(1) 
graph export "coefplot_combined_`x'.pdf", replace
}



****APPENDIX
*
* ---------------------------
*7. INSTRUMENTAL VARIABLES - HOMICIDES
* ---------------------------
clear
use "main_data"

g lmsbs = lmassas if ano_morte == 2001
by codmun, sort: egen lmsbs2 = max(lmsbs) 
g trend2 = lmsbs2*codmun
g trendhom = codmun*tx_homicidio_total 
g trendm = codmun*lmassas 

foreach a in  tx_firmas tx_total      {
xtivreg2 `a' lmassa trendm (tx_homicidio_total = trat) [aweight=meanmpop]   if grupo!=., fe first cluster(uf3)
outreg2 using "iv_homic.xls"
}
xtreg `e(instd)' `e(insts)'  if e(sample) & grupo!=. [aweight=meanmpop], fe cluster(uf3)
outreg2 using "iv_homic.xls"



* ---------------------------
*8. ROBUSTNESS CSDID
* ---------------------------
*8.1 São Paulo
* ---------------------------

clear
use "main_data"
drop if uf3==35

 
foreach a in tx_firmas tx_total {
csdid2 `a'  lmassas [aweight=meanmpop], i(codmun) t(ano_morte) gvar(grupo) cluster(uf3)  notyet  
estat simple
outreg2 using "csdidnyt.xls"
estat event , revent(-4/8)
outreg2 using "csdidnyt.xls"
	estat event, revent(-6/8)
	matrix T = r(table)	
	matrix R=r(table)
	matrix CSp=J(16, 3, .)
	matrix rownames CSp = "-6" "-5" "-4" "-3" "-2" "0" "1" "2" "3" "4" "5" "6" "7" "8"
	local j=0
	forvalues i=1/16 {
		matrix CSp[`i',1]=R[1,`=`j'+3']
		matrix CSp[`i',2]=R[5,`=`j'+3']
		matrix CSp[`i',3]=R[6,`=`j'+3']
		local j=`j'+1
	}	
coefplot (matrix(CSp[,1]), ci((2 3)) pstyle(p4) msymbol(O) ciopts(recast(rcap) lpattern(solid) lcolor(black))), ///
	vertical graphregion(color(white)) bgcolor(white) ///
	xlabel(, noticks) ylabel(, noticks nogrid) xtitle("Years") ///
	ytitle("Average causal effect") yline(0, lcolor("182 39 37") lpattern(solid)) ///
	xline(5.5, lwidth(thin) lcolor(black)  lpattern(dash)) 
	graph export "csdid_semsp_`a'.pdf", replace
}


* ---------------------------
*8. ROBUSTNESS CSDID
* ---------------------------
*8.2 Minas Gerais (Revisiting Soares and Viveiros (2010)
*Instrumental Variables, RFs, and csdid2
* ---------------------------

clear
use "reproduction_sv2010_with_econ_data"


foreach x in tx_cvcpatr tx_homicid tx_cnvcpatr {
gen lag1_`x' = `x'[_n-1] if codigo==codigo
gen lag2_`x' = `x'[_n-2] if codigo==codigo
gen lag3_`x' = `x'[_n-3] if codigo==codigo
}

 

xtset codigo ano
xtreg tx_count_estabelecimentos tratam tx_cnvcpatr tx_cvcpatr tx_homicid lag*  [aweight=meanpop] , fe r
outreg2 using "xtreg.xls"
xtreg tx_count_total_empregados tratam tx_cnvcpatr tx_cvcpatr tx_homicid lag* [aweight=meanpop] , fe r
outreg2 using "xtreg.xls"
xtreg pibpc tratam tx_cnvcpatr tx_cvcpatr tx_homicid lag* [aweight=meanpop] , fe r
outreg2 using "xtreg.xls"



xtivreg2 tx_count_estabelecimentos (tx_cvcpatr = tratam) [aweight=meanpop],  fe
outreg2 using "iv_mg_patrimonio.xls"
xtivreg2 tx_count_total_empregados (tx_cvcpatr = tratam) [aweight=meanpop],  fe
outreg2 using "iv_mg_patrimonio.xls"
xtreg `e(instd)' `e(insts)' if e(sample) [aweight=meanpop], fe
outreg2 using "iv_mg_patrimonio.xls"


xtivreg2 tx_count_estabelecimentos (tx_cnvcpatr = tratam) [aweight=meanpop], first fe
outreg2 using "iv_mg_patrimonio.xls"
xtivreg2 tx_count_total_empregados (tx_cnvcpatr = tratam) [aweight=meanpop],  fe
outreg2 using "iv_mg_patrimonio.xls"
xtreg `e(instd)' `e(insts)' if e(sample) [aweight=meanpop], fe
outreg2 using "iv_mg_patrimonio.xls"

xtivreg2 tx_count_estabelecimentos (tx_homicid = tratam) [aweight=meanpop], first fe
outreg2 using "iv_mg_patrimonio.xls"
xtivreg2 tx_count_total_empregados (tx_homicid = tratam) [aweight=meanpop],  fe
outreg2 using "iv_mg_patrimonio.xls"
xtreg `e(instd)' `e(insts)' if e(sample) [aweight=meanpop], fe
outreg2 using "iv_mg_patrimonio.xls"


set scheme sj
 
 
csdid2 tx_cvcpatr  pibpc [aweight=meanpop] , ivar(codigo) time(ano) gvar(ano_trat) notyet
estat simple
estat event , window(-3 4) 
csdid2_plot ,  legend(off)
graph export "csdid_mg_cvp.pdf", replace
 
 
csdid2 tx_cnvcpatr  pibpc [aweight=meanpop] , ivar(codigo) time(ano) gvar(ano_trat) notyet
estat simple
estat event , window(-3 3) 
csdid2_plot ,  legend(off)
graph export "csdid_mg_cnvp.pdf", replace
 
