* Tabulate homicides by state, year, and age group

capture conren style 5
set more off

use "output/gundeath.dta", clear
keep if inrange(res_stat, 1, 3)  // U.S. residents only
keep if !mi(occ_usps)

// create age groups
gen str age_grp = "adult_" if inrange(age, 21, 150)
replace age_grp = "juv_" if inrange(age, 12, 17)
replace age_grp = "youth_" if inrange(age, 18, 20)
replace age_grp = "child_" if inrange(age, 0, 11)
replace age_grp = "norep_" if mi(age)
assert !mi(age_grp)

gen byte firearm_hom = firearm == 1 & homicide == 1
gen byte firearm_sui = firearm == 1 & suicide == 1

collapse (sum) firearm* homicide suicide, by(occ_usps year age_grp) fast
reshape wide @firearm_hom @firearm_sui @firearm @homicide @suicide /*
    */ , i(occ_usps year) j(age_grp) string

foreach v of varlist *firearm* *homicide *suicide {
    qui replace `v' = 0 if mi(`v')
}

// homicide tabulations
egen long all_homicide = rowtotal(*_homicide)
gen long anyage_homicide = all_homicide - norep_homicide
gen long nonjuv_homicide = all_homicide - juv_homicide

// suicide tabulations
egen long all_suicide = rowtotal(*_suicide)
gen long anyage_suicide = all_suicide - norep_suicide
gen long nonjuv_suicide = all_suicide - juv_suicide

// firearm tabulations
egen long all_firearm = rowtotal(*_firearm)
gen long anyage_firearm = all_firearm - norep_firearm
gen long nonjuv_firearm = all_firearm - juv_firearm
egen long all_firearm_hom = rowtotal(*_firearm_hom)
gen long anyage_firearm_hom = all_firearm_hom - norep_firearm_hom
gen long nonjuv_firearm_hom = all_firearm_hom - juv_firearm_hom
egen long all_firearm_sui = rowtotal(*_firearm_sui)
gen long anyage_firearm_sui = all_firearm_sui - norep_firearm_sui
gen long nonjuv_firearm_sui = all_firearm_sui - juv_firearm_sui

statez occ_usps, from(usps) to(fips)
capture rename (occ_usps _FIPS_) (usps fips)
destring fips, replace

keeporder fips usps year all_* adult_* juv_* nonjuv_* anyage_*

loc lblall "total"
loc lbladult "adult (21+)"
loc lbljuv "juvenile (12-17)"
loc lblnonjuv "non-juvenile (age not 12-17)"
loc lblanyage "any reported age (age not missing)"

foreach age in all adult juv nonjuv anyage {
    la var `age'_homicide    "Number of `lbl`age'' homicides"
    la var `age'_suicide     "Number of `lbl`age'' suicides"
    la var `age'_firearm     "Number of `lbl`age'' firearm-related deaths"
    la var `age'_firearm_hom "Number of `lbl`age'' firearm homicides"
    la var `age'_firearm_sui "Number of `lbl`age'' firearm suicides"
}

qui compress
qui sum year
la data "Violent deaths by state, `r(min)'-`r(max)'"
save "output/violent_death.dta", replace
exit
